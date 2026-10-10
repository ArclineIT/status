# arcline-status — Status Page

The state of each service, incidents with updates, scheduled maintenance and
history. Self-hosted at status.arclineit.com.

## Stack
- Ruby on Rails 8.1 + SQLite
- Admin area behind HTTP basic auth
- Optional static output: single-file HTML with inlined CSS

## Done
- [x] Rails app (replaces the planned Go generator)
- [x] Components with operational / degraded / outage / maintenance states
- [x] Incidents with severity and a timeline of updates
- [x] Scheduled maintenance, with state following the clock
- [x] Public page: current status, active incidents, upcoming maintenance
- [x] History page (resolved incidents, 90-day window)
- [x] Admin area: set states, open and update incidents, schedule maintenance
- [x] YAML import and validation (`status:import`, `status:validate`)
- [x] Static export, one self-contained file per page (`status:build`)
- [x] JSON status and an Atom feed
- [x] Example status.yaml
- [x] README with self-hosting guide (nginx snippet)

## Ideas
- [ ] Sign in through Nexus instead of basic auth
- [ ] Set component states automatically from arcline-uptime
- [ ] Email or webhook subscribers for incident updates
- [ ] Link an incident to the components it affects
- [ ] Rebuild the static pages automatically after each change
- [ ] Uptime bars per component
