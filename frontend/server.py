#!/usr/bin/env python3

# @file frontend/server.py
# @brief Static file server for frontend
# @description Simple HTTP server for development

import http.server
import socketserver
import os

PORT = 3000
DIRECTORY = "public"

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)
    
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"🌐 Frontend server running at http://localhost:{PORT}")
        print(f"📁 Serving files from: {DIRECTORY}")
        print("Press Ctrl+C to stop")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Server stopped")