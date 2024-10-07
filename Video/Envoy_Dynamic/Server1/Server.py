from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse
import os.path
import subprocess
import threading
import shlex
import time

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        path=self.path[1:]
        #health check
        if path=="health":
            self.send_response(200)
            self.end_headers()
            Resp= "Health check!" +"\n\n"
            self.wfile.write(Resp.encode())
        elif(os.path.isfile(path)):
            self.send_response(200)
            self.end_headers()
            client = self.client_address[0]
            Resp="Sending " + path + " to client: " +client +"\n\n"
            self.wfile.write(Resp.encode())
            threading.Thread(target=self.startStream, args=(client,path)).start()

        else:
            self.send_response(404)
            self.end_headers()
            client=self.client_address[0]
            Resp= path + " Not found! to send to " +client +"\n\n"
            self.wfile.write(Resp.encode())

    def startStream(self, client,path):
        #for client use 
        #ffmpeg -err_detect ignore_err  -fflags +genpts -i "udp://@192.168.170.128:6666?buffer_size=65535&timeout=10000000&fifo_size=500000" -c copy outputfile.mp4 2>&1 | tee -a log.txt
        #run with
        #ffplay outputfile.mp4
        #gather statistics with 
        #ffmpeg -v error -i outputfile.mp4 -f null - 2>&1 | tee -a stats.txt
        #cmd = f'ffmpeg -i {path} -c:v libx264 -fflags +genpts -preset ultrafast -movflags faststart -f mpegts udp://{client}:7000'       
        cmd = f'ffmpeg -re -i {path} -c:v libx264 -fflags +genpts -preset fast -bufsize 3968k -movflags faststart -f mpegts udp://{client}:7000'

        subprocess.run(cmd.split())


httpd = HTTPServer(('', 8888), Handler)
print("Server will be running on localhost, listening to port 8888 and returns to port 7000 of the requester")
httpd.serve_forever()
