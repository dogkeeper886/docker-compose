#!/usr/bin/env python3
"""Prometheus exporter for Ollama loaded models."""

import json
import os
import urllib.request
from http.server import HTTPServer, BaseHTTPRequestHandler


OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434")
PORT = int(os.environ.get("EXPORTER_PORT", "9836"))


def fetch_loaded_models():
    try:
        req = urllib.request.Request(f"{OLLAMA_URL}/api/ps")
        with urllib.request.urlopen(req, timeout=5) as resp:
            return json.loads(resp.read())["models"]
    except Exception:
        return []


def escape_label(value):
    return str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def generate_metrics():
    models = fetch_loaded_models()
    lines = []
    lines.append("# HELP ollama_model_vram_bytes VRAM bytes used by a loaded Ollama model")
    lines.append("# TYPE ollama_model_vram_bytes gauge")
    for m in models:
        details = m.get("details", {})
        labels = {
            "model": m.get("model", ""),
            "parameter_size": details.get("parameter_size", ""),
            "quantization": details.get("quantization_level", ""),
            "context_length": str(m.get("context_length", "")),
        }
        label_str = ",".join(f'{k}="{escape_label(v)}"' for k, v in labels.items())
        lines.append(f"ollama_model_vram_bytes{{{label_str}}} {m.get('size_vram', 0)}")
    return "\n".join(lines) + "\n"


class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/metrics":
            body = generate_metrics().encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), MetricsHandler)
    print(f"Ollama exporter listening on :{PORT}")
    server.serve_forever()
