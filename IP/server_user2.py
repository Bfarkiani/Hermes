import asyncio
import os
import fcntl
import select
import struct
import socket
import ipaddress
from typing import Dict, Tuple,List
import subprocess
import logging
import signal

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)


def config_nat(tunnel_name: str = 'tun0', outbound_interface: str = 'enp1s0', action: str = 'start'):
    try:
        run_command('sysctl -w net.ipv4.ip_forward=1')

        iptable_action = '-A' if action == 'start' else '-D'

        commands = [
            f'iptables {iptable_action} FORWARD -i {tunnel_name} -o {outbound_interface} -j ACCEPT',
            f'iptables {iptable_action} FORWARD -i {outbound_interface} -o {tunnel_name} -j ACCEPT',
            f'iptables -t nat {iptable_action} POSTROUTING -o {outbound_interface} -j MASQUERADE'
        ]

        for cmd in commands:
            run_command(cmd)

        logger.info(f"NAT configuration {'started' if action == 'start' else 'stopped'}")
    except Exception as e:
        logger.error(f"Exception in config_nat: {e}")
        raise

def run_command(command: str) -> List[str]:
    try:
        process = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        return [process.stdout.strip()]
    except subprocess.CalledProcessError as e:
        logger.error(f"Error executing command: {command}")
        logger.error(f"Error message: {e.stderr}")
        raise


def create_tun(name: str = 'tun0', ip:str = '10.0.0.1/24') -> int:
    #https://gist.github.com/glacjay/585369/b229da72a0dc84dd27d12afc5b76d0c5c44bb9c3

    TUNSETIFF = 0x400454ca
    IFF_TUN = 0x0001
    IFF_NO_PI = 0x1000
    TUNSETOWNER = TUNSETIFF + 2
    try:
        tun = os.open('/dev/net/tun', os.O_RDWR)
        ifr = struct.pack('16sH', name.encode('ascii'), IFF_TUN | IFF_NO_PI)
        fcntl.ioctl(tun, TUNSETIFF, ifr)
        fcntl.ioctl(tun, TUNSETOWNER, 1000)
        run_command(f"ip addr add {ip} dev {name}")
        run_command(f"ip link set dev {name} up")
        return tun
    except Exception as e:
        logger.error(f"Error in creating tunnel: {e}")
        raise


def get_ip_info(packet: bytes) -> Tuple[ipaddress.IPv4Address, ipaddress.IPv4Address]:
    ip_header = packet[:20]
    header = struct.unpack('!BBHHHBBH4s4s', ip_header)
    src_ip = ipaddress.ip_address(header[8])
    dst_ip = ipaddress.ip_address(header[9])
    return dst_ip, src_ip


class UDPServer:
    def __init__(self, sock: socket.socket, tunnel: int):
        self.clients: Dict[ipaddress.IPv4Address, Tuple[str, int]] = {}
        self.socket = sock
        self.tunnel = tunnel

    def send(self, data: bytes, addr: ipaddress.IPv4Address):
        #this is tunnel ip of peer
        if addr in self.clients:
            self.socket.sendto(data, self.clients[addr])
            logger.info(f"Packet sent to {self.clients[addr]}")
        else:
            logger.warning(f"No route found for {addr}")

    def read(self):
        try:
            #addr is encapsulated udp ip address and port: after nat
            data, addr = self.socket.recvfrom(1500)
            #src_ip is tunnel ip of remote client. dest_ip is target
            dst_ip, src_ip = get_ip_info(data)
            logger.info(f"Packet from server to {dst_ip}")
            #we need to keep track to find to which peer we need to send the result back
            self.clients[src_ip] = addr
            #give it to os to handle it
            os.write(self.tunnel, data)
            logger.info("Received packet from server and wrote to TUN")
        except Exception as e:
            logger.error(f"Error in read_udp: {e}")


def read_tunnel(tunnel: int, udp_server: UDPServer):
    try:
        buf = os.read(tunnel, 1500)
        #this is after nat, src is target and destination is our peer
        dest, src = get_ip_info(buf)
        logger.info(f"Packet source: {src}, destination: {dest}")
        #we already should now a mapping between peer udp endpoint and it tunnel ip
        if dest in udp_server.clients:
            udp_server.send(buf, dest)
            logger.info("Received packet from tunnel and wrote to socket")
        else:
            logger.warning(f"No route found for {dest}")
    except Exception as e:
        logger.error(f"Error in read_tunnel: {e}")


async def run_select(tun: int, sock: socket.socket, udp_server: UDPServer, stop_event: asyncio.Event):
    inputs = [tun, sock]
    loop = asyncio.get_running_loop()

    while stop_event.is_set()==False:
        try:
            rlist, _, _ = await loop.run_in_executor(None, select.select, inputs, [], [], 1.0)
            for fd in rlist:
                if tun in rlist:
                    await loop.run_in_executor(None, read_tunnel, tun, udp_server)
                elif sock in rlist:
                    await loop.run_in_executor(None, udp_server.read)
        except Exception as e:
            logger.error(f"An error occurred in run_select: {e}")
            break


async def main():
    output_interface='enp1s0'
    tunnel_name='tun0'
    tunnel_ip='10.0.0.1/24'
    listen_port = 21000
    #initializing

    tun = create_tun(tunnel_name,tunnel_ip)
    config_nat(tunnel_name, output_interface, 'start')
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('0.0.0.0', listen_port))
    udp_server = UDPServer(sock, tun)

    stop_event = asyncio.Event()
    buffer_size = 65536  
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, buffer_size)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, buffer_size)
    #setting interrupt handler
    loop = asyncio.get_running_loop()
    loop.add_signal_handler(signal.SIGINT, stop_event.set)
    loop.add_signal_handler(signal.SIGTERM, stop_event.set)

    #running
    try:
        while not stop_event.is_set():
            try:
                rlist, _, _ = await loop.run_in_executor(None, select.select, [sock,tun], [], [], 1.0)
                for fd in rlist:
                    if fd == tun:
                        await loop.run_in_executor(None, read_tunnel, tun, udp_server)
                    elif fd == sock:
                        await loop.run_in_executor(None, udp_server.read)
            except Exception as e:
                logger.error(f"An error occurred: {e}")
                break

        await stop_event.wait()
    except asyncio.CancelledError:
        logger.info("Main task cancelled.")
    finally:
        logger.info("Cleaning up...")
        config_nat(tunnel_name, output_interface, 'stop')
        os.close(tun)
        sock.close()
        logger.info("Done")


if __name__ == '__main__':
    asyncio.run(main())
