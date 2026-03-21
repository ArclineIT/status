# arcline-status

Static status page generator. Reads a YAML config and produces a single-file HTML status page — no database, no SaaS, no external dependencies.

Designed to be self-hosted at `status.arclineit.com` and regenerated on a cron/systemd timer.

## Status

Planned. Not yet started.

## Stack

- Go — single static binary
- Config: YAML
- Output: static HTML with all CSS inlined (no asset dependencies)

## Usage

```sh
arcline-status build --config status.yaml --out ./public
arcline-status build --config status.yaml --out ./public --watch
arcline-status serve --config status.yaml --port 8080
arcline-status validate --config status.yaml
```

## Config

```yaml
site:
  title: "Arcline Status"
  domain: "status.arclineit.com"

components:
  - name: "Shared Hosting"
    status: operational     # operational | degraded | outage | maintenance

incidents:
  - title: "Brief network disruption"
    status: resolved
    severity: minor
    started: "2026-02-28T14:00:00Z"
    resolved: "2026-02-28T15:30:00Z"
    updates:
      - time: "2026-02-28T14:00:00Z"
        body: "Investigating."
      - time: "2026-02-28T15:30:00Z"
        body: "Resolved. Root cause: upstream BGP flap."
```

## Output pages

- `index.html` — current status, active incidents, upcoming maintenance
- `history.html` — past incidents (90-day window)

See [todo.md](todo.md) for the full task list.

## License

MIT — see [LICENSE](LICENSE).
