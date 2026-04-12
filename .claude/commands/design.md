You are designing a Grafana dashboard or Docker Compose service for this repository.

## Input

$ARGUMENTS

## Process

### 1. Understand the requirement
- What service or metrics are involved?
- What is the target audience (SRE, developer, operator)?
- What decisions should the dashboard or service help make?

### 2. For Grafana dashboards, apply the inverted pyramid layout

| Priority | Row | Content |
|----------|-----|---------|
| 1 | Top | **Stat panels** — single-value indicators for instant health check (utilization, error rate, saturation). Answer: "is everything OK?" |
| 2 | Middle | **Time series** — trends for key metrics. Answer: "is something getting worse?" |
| 3 | Lower | **Detail panels** — breakdowns, per-instance drill-downs. Answer: "what exactly is happening?" |
| 4 | Bottom | **Reference** — static/rarely-changing info in collapsed rows. Answer: "what is this thing?" |

**Panel design rules:**
- Use template variables for multi-instance filtering (e.g., `$uuid`, `$instance`)
- Set meaningful color thresholds (green/yellow/red) on all stat and gauge panels
- Use `palette-classic` color mode for time series with multiple series
- Set appropriate units on every panel (percent, bytes, celsius, watt, etc.)
- Use `file_sd_configs` for Prometheus targets — never hardcode IPs in committed files
- Auto-refresh interval: 30s for operational dashboards

### 3. For Docker Compose services, follow repo conventions
- NVIDIA runtime where GPU acceleration applies
- `TZ=Asia/Taipei` on all containers
- `restart: unless-stopped`
- Persistent volumes under `./volume/` (gitignored)
- Secrets and IPs go in `.env` or target files (gitignored), with `.example` committed
- Port mappings must not conflict with existing services

### 4. Output
- Describe the proposed layout with a table of panels/services
- List files to create or modify
- Flag any port conflicts or dependency concerns
- Ask for confirmation before implementing
