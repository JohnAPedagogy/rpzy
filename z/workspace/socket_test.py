import socket
import os
import sys

sock_path = "test.sock"
print(f"Testing socket creation in {os.getcwd()}")

if os.path.exists(sock_path):
    try:
        os.remove(sock_path)
    except OSError:
        pass

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
    s.bind(sock_path)
    print("Socket created successfully")
except OSError as e:
    print(f"Error creating socket: {e}")
finally:
    s.close()
    if os.path.exists(sock_path):
        try:
            os.remove(sock_path)
        except OSError:
            pass
