import socket
import threading

# Define addresses and ports
client_address = ('192.168.14.1', 6363)
server_address = ('192.168.4.2', 6363)
middle_program_address = ('0.0.0.0', 12000)  # Listen on all interfaces
server_response_address = ('0.0.0.0', 8000)  # Listen on all interfaces

# Create sockets
middle_program_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Bind the middle program socket to port 12000
middle_program_socket.bind(middle_program_address)

# Bind the server socket to port 8000 to send data to and receive responses from the server
server_socket.bind(server_response_address)

def handle_client_to_server():
    while True:
        # Receive interest from client on port 12000
        data, addr = middle_program_socket.recvfrom(65535)  # Using a large buffer for potentially big messages
        print(f"Received interest from client at {addr}")

        # Forward interest to the server on port 6363
        server_socket.sendto(data, server_address)
        print(f"Forwarded interest to server from {addr}")

def handle_server_to_client():
    while True:
        # Receive data from the server on port 8000
        response_data, server_addr = server_socket.recvfrom(65535)
        print(f"Received data from server at {server_addr}")

        # Forward data back to the client using the middle program socket on port 12000
        middle_program_socket.sendto(response_data, client_address)
        print("Forwarded data to client")

# Create threads for handling communication
client_to_server_thread = threading.Thread(target=handle_client_to_server)
server_to_client_thread = threading.Thread(target=handle_server_to_client)

# Start the threads
client_to_server_thread.start()
server_to_client_thread.start()

# Join the threads
client_to_server_thread.join()
server_to_client_thread.join()
