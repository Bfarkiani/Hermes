import asyncio
import os
import fcntl
import select
import struct
import socket
import ipaddress
from typing import List, Tuple,Dict
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

def create_tun(name: str = 'tun0', ip:str = '10.0.0.2/24') -> int:
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


def server_endpoints(destinations: Dict[str,Tuple[str,int]]) -> Tuple[List[ipaddress.IPv4Network], List[Tuple[str, int]]]:
    addresses = list(destinations.values())
    networks = [ipaddress.ip_network(k) for k in destinations.keys()]
    return networks, addresses


def manage_routes(action: str, routes:List[str], name: str = 'tun0'):
    for route in routes:
        run_command(f"ip route {action} {route} dev {name}")


def get_destination_ip(packet: bytes) -> Tuple[ipaddress.IPv4Address, ipaddress.IPv4Address]:
    ip_header = packet[:20]
    header = struct.unpack('!BBHHHBBH4s4s', ip_header)
    src_ip = ipaddress.ip_address(header[8])
    dst_ip = ipaddress.ip_address(header[9])
    return dst_ip, src_ip


def read_tunnel(tunnel: int, sock: socket.socket, endpoints: List[ipaddress.IPv4Network],
                addresses: List[Tuple[str, int]]):
    try:
        buf = os.read(tunnel, 1500)
        dest, src = get_destination_ip(buf)
        logger.info(f"Packet source: {src}, destination: {dest}")

        ip = ipaddress.ip_address(dest)
        addr = next((addresses[i] for i, network in enumerate(endpoints) if ip in network), None)

        if addr:
            sock.sendto(buf, addr)
            logger.info("Received packet from tunnel and wrote to socket")
        else:
            logger.info(f"No route found for {ip}")
    except Exception as e:
        logger.error(f"Error in read_tunnel: {e}")
        raise


def read_udp(tunnel: int, sock: socket.socket):
    try:
        data, _ = sock.recvfrom(1500)
        dst_ip, _ = get_destination_ip(data)
        logger.info(f"Packet from server to {dst_ip}")
        os.write(tunnel, data)
        logger.info("Received packet from server and wrote to TUN")
    except Exception as e:
        logger.error(f"Error in read_udp: {e}")
        raise


async def main():
    #names
    output_interface='ens33'
    tunnel_name='tun0'
    tunnel_ip='10.0.0.10/24'
    udp_endpoints = {
        '10.0.0.1/32': ('192.168.170.129', 10000),
        '10.0.0.2/32': ('192.168.170.129', 10001),
        '128.252.0.0/16': ('192.168.170.129', 10002)
    }
    #vpn routes
    routes = [
        "10.0.0.2/32",
        "128.252.0.0/16",
        "10.0.0.1/32"
    ]
    #initialization. setting tunnel name and its ip address
    tun = create_tun(tunnel_name,tunnel_ip)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    config_nat('tun0',output_interface,'start')

    #setting ip table routes
    manage_routes('add',routes, tunnel_name)

    #managing udp endpoints
    endpoints, addresses = server_endpoints(udp_endpoints)
    #setting interrupt handler
    stop_event=asyncio.Event()
    loop = asyncio.get_running_loop()
    loop.add_signal_handler(signal.SIGINT, stop_event.set)
    loop.add_signal_handler(signal.SIGTERM, stop_event.set)

    #running
    try:
        while not stop_event.is_set():
            try:
                rlist, _, _ = await loop.run_in_executor(None, select.select, [sock,tun], [], [], 1)
                for fd in rlist:
                    if fd == tun:
                        await loop.run_in_executor(None, read_tunnel, tun, sock,endpoints,addresses)
                    elif fd == sock:
                        await loop.run_in_executor(None, read_udp,tun,sock)
            except Exception as e:
                logger.error(f"An error occurred: {e}")
                break

        await stop_event.wait()
    except asyncio.CancelledError:
        logger.info("Main task cancelled.")
    finally:
        logger.info("Cleaning up...")
        manage_routes('del', routes, tunnel_name)
        config_nat(tunnel_name, output_interface, 'stop')

        os.close(tun)
        sock.close()
        logger.info("Done")





if __name__ == '__main__':
    asyncio.run(main())
