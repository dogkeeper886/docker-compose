# GPU Exporter

NVIDIA GPU metrics exporter for Prometheus. Exposes GPU metrics on port `9835` for the host monitoring stack to scrape.

Uses [nvidia_gpu_exporter](https://github.com/utkuozdemir/nvidia_gpu_exporter) which works with all NVIDIA GPUs including older architectures (Kepler/K80, compute capability 3.7).

## Quick Start

```bash
make up
make test
```

## Metrics Endpoint

```
http://<instance-ip>:9835/metrics
```

## Prometheus Scrape Config (on host)

Add this to the host's `prometheus.yml`:

```yaml
- job_name: 'nvidia-gpu'
  static_configs:
    - targets: ['<instance-ip>:9835']
      labels:
        instance: '<instance-name>'
```

## Exported Metrics

| Metric | Description |
|--------|-------------|
| `nvidia_gpu_temperature_celsius` | GPU temperature |
| `nvidia_gpu_utilization_gpu_ratio` | GPU utilization (0-1) |
| `nvidia_gpu_utilization_memory_ratio` | Memory utilization (0-1) |
| `nvidia_gpu_memory_used_bytes` | Memory used |
| `nvidia_gpu_memory_total_bytes` | Memory total |
| `nvidia_gpu_memory_free_bytes` | Memory free |
| `nvidia_gpu_power_draw_watts` | Power draw |
| `nvidia_gpu_clock_graphics_hz` | Graphics clock |
| `nvidia_gpu_clock_sm_hz` | SM clock |
| `nvidia_gpu_clock_memory_hz` | Memory clock |
| `nvidia_gpu_fan_speed_ratio` | Fan speed (0-1) |

## Grafana Dashboard

Import dashboard ID `14574` (NVIDIA GPU Metrics) on the host Grafana, using the Prometheus data source that scrapes this exporter.

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start exporter |
| `make down` | Stop exporter |
| `make restart` | Restart exporter |
| `make logs` | Show logs |
| `make ps` | Show status |
| `make test` | Curl metrics endpoint |
| `make clean` | Stop and remove volumes |

## Notes

- Requires NVIDIA drivers installed on the host (nvidia-smi accessible)
- Mounts nvidia-smi and libnvidia-ml.so from the host into the container
- Compatible with Tesla K80 (driver 470.x, CUDA 11.4, compute 3.7)
- No GPU runtime needed — reads metrics via NVML, does not run GPU workloads
