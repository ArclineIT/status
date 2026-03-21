# arcline-status — Static Status Page Generator

A Go binary that reads a YAML config and generates a static HTML status page.
No database, no SaaS, no external dependencies. Customers self-host at status.yourdomain.com.

## Stack
- Language: Go
- Output: static HTML (single file or directory)
- Config: YAML
- Optional: cron job or systemd timer for auto-regeneration

## Config format (status.yaml)
```yaml
site:
  title: "Arcline Status"
  domain: "status.arclineit.com"
  logo: "[arcline]"

components:
  - name: "Shared Hosting"
    status: operational        # operational | degraded | outage | maintenance
  - name: "VPS Hosting"
    status: operational
  - name: "Control Panel"
    status: operational
  - name: "DNS / Nameservers"
    status: operational
  - name: "SSL Provisioning"
    status: operational
  - name: "Network"
    status: operational

incidents:
  - id: 1
    title: "Brief network disruption"
    status: resolved           # investigating | identified | monitoring | resolved
    severity: minor            # minor | major | critical
    started: "2026-02-28T14:00:00Z"
    resolved: "2026-02-28T15:30:00Z"
    updates:
      - time: "2026-02-28T14:00:00Z"
        body: "Investigating reports of connectivity issues."
      - time: "2026-02-28T15:30:00Z"
        body: "Issue resolved. Root cause: upstream BGP flap."

maintenance:
  - title: "NVMe storage upgrade"
    status: scheduled
    starts: "2026-03-10T02:00:00Z"
    ends: "2026-03-10T04:00:00Z"
    body: "Brief VPS downtime expected during storage migration."
```

## Output
- `index.html` — current status (all components, active incidents, upcoming maintenance)
- `history.html` — past incidents (90-day window)
- Arcline terminal aesthetic (matches brand CSS)
- Embeds all CSS/JS inline — truly single-file, no asset dependencies

## CLI interface
```
arcline-status build --config status.yaml --out ./public
arcline-status build --config status.yaml --out ./public --watch   # rebuild on config change
arcline-status serve --config status.yaml --port 8080              # dev server
arcline-status validate --config status.yaml                       # lint config
```

## Tasks
- [ ] Project scaffold
- [ ] YAML config parser + validator
- [ ] HTML template (Go text/template, embed Arcline CSS inline)
- [ ] Component status renderer (operational/degraded/outage/maintenance badges)
- [ ] Active incident renderer
- [ ] Maintenance banner renderer
- [ ] History page (filter resolved incidents)
- [ ] --watch mode (fsnotify)
- [ ] Dev serve mode (net/http)
- [ ] validate subcommand
- [ ] Single-file output (inline all CSS)
- [ ] README with self-hosting guide (nginx config snippet)
- [ ] Example status.yaml
- [ ] Cross-compile Makefile
