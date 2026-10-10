# Arcline Status

A status page: the state of each service, open incidents with their updates,
scheduled maintenance, and a 90-day incident history.

This was planned as a Go generator that turned a YAML file into static HTML.
It is built instead as a Ruby on Rails app with an admin area, so an incident
can be opened and updated from a browser. Both of the original ideas are kept:
a `status.yaml` can be imported, and the page can be written out as static,
single-file HTML.

## Pages

| Path | Login | Description |
|---|---|---|
| `/` | no | Current status, open incidents, upcoming maintenance |
| `/history` | no | Resolved incidents from the last 90 days, and past maintenance |
| `/status.json` | no | The current status as JSON |
| `/feed.xml` | no | Atom feed of incidents |
| `/admin` | yes | Set component states, open and update incidents, schedule maintenance |

## Running an incident

1. In `/admin`, choose **Open incident**, give it a title, a severity and a
   first update.
2. Set the affected components to *Degraded performance* or *Outage*.
3. Post updates as you learn more: *Investigating*, *Identified*, *Monitoring*.
4. Post a final update with the status *Resolved*. The incident moves to the
   history page. Set the components back to *Operational*.

An open incident changes the page's headline even if no component has been
changed yet.

## Requirements

- Ruby 4.0+
- SQLite 3 (bundled via the `sqlite3` gem)

## Setup

```bash
bin/setup --skip-server   # install gems and prepare the database
cp .env.example .env      # then fill in your values
bin/rails server          # http://localhost:3000, or PORT if set
```

To start from the example components:

```bash
bin/rails 'status:import[status.example.yaml]'
```

## Importing a status.yaml

```bash
bin/rails 'status:validate[status.yaml]'   # check the file, change nothing
bin/rails 'status:import[status.yaml]'
```

The file format is the one designed for the original generator; see
`status.example.yaml`. Components are matched by name, and incidents and
maintenance by title and start time, so importing the same file again updates
rather than duplicates. The `site:` section is not used: set `STATUS_TITLE`
instead.

## Static export

```bash
bin/rails 'status:build[/var/www/status]'
```

This writes `index.html` and `history.html` with all CSS inlined and no
scripts or external files. Use it to serve the status page from a different
host than the one it reports on, so the page survives an outage of the app
itself. Run it from cron or after each change.

```nginx
server {
    listen 443 ssl;
    server_name status.arclineit.com;
    root /var/www/status;
    index index.html;
}
```

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `3000` | HTTP listen port |
| `DATABASE_PATH` | `storage/<env>.sqlite3` | SQLite database file |
| `STATUS_TITLE` | `Arcline Status` | Page title |
| `STATUS_BASE_URL` | `https://status.arclineit.com` | Public address, used in the feed |
| `STATUS_USERNAME` | — | Admin username (HTTP basic auth) |
| `STATUS_PASSWORD` | — | Admin password |

In production the admin area refuses to load until `STATUS_USERNAME` and
`STATUS_PASSWORD` are set. In development it is open when they are unset. The
public pages never need a login.

## Tests

```bash
bin/rails test
bin/rubocop
bin/brakeman
```

## Deployment

The app ships with a `Dockerfile` and a Kamal config (`config/deploy.yml`).
The SQLite database lives in `storage/`, which is mounted as a volume.

## License

MIT. See [LICENSE](LICENSE).
