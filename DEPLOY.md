# Deploying the campaign server (Railway)

This server (TFS revscriptsys + the campaign scripts in
[`data/scripts/campaign/`](data/scripts/campaign/README.md)) is a native
process that needs a persistent TCP connection and a MySQL database, so it
**cannot run on Vercel**. Railway (or any host that runs long-lived Docker
containers + MySQL) works. The client (OTClientV8 web build) is a separate,
static deployment - see the main `NewWorldTest` repo for that.

## 1. Create the Railway project

1. Sign in to [Railway](https://railway.app) and create a new project.
2. **New -> Database -> Add MySQL.** Railway provisions a MySQL instance and
   exposes connection variables on that service (open its **Variables** tab -
   names are typically `MYSQLHOST`, `MYSQLUSER`, `MYSQLPASSWORD`,
   `MYSQLDATABASE`, `MYSQLPORT`; double check the exact names in your project).
3. **New -> GitHub Repo** and select `OldSchoolRPG/forgottenserver` (branch
   `master`). Railway detects the root `Dockerfile` automatically - no build
   config needed.

## 2. Configure environment variables on the server service

Open the server service -> **Variables** and add:

| Variable | Value |
|---|---|
| `MYSQL_HOST` | `${{MySQL.MYSQLHOST}}` (reference the MySQL service) |
| `MYSQL_USER` | `${{MySQL.MYSQLUSER}}` |
| `MYSQL_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}` |
| `MYSQL_DATABASE` | `${{MySQL.MYSQLDATABASE}}` |
| `MYSQL_PORT` | `${{MySQL.MYSQLPORT}}` |
| `SERVER_NAME` | e.g. `OldSchool Campaign` |
| `WORLD_TYPE` | `pvp`, `no-pvp`, or `pvp-enforced` |

`${{Service.VAR}}` is Railway's variable-reference syntax - typing `${{` in
the variable editor lets you pick the MySQL service and variable from a list,
so you don't need to copy secrets by hand.

On boot, [`docker-entrypoint.sh`](docker-entrypoint.sh) regenerates
`config.lua` from `config.lua.dist` plus these variables, and imports
`schema.sql` into the database automatically the first time it finds no
`server_config` table.

## 3. Expose the game ports

TFS speaks raw TCP on two ports - `7171` (status/login) and `7172` (game).
In the server service -> **Settings -> Networking -> TCP Proxy**, add a proxy
for each port (`7171` and `7172`). Railway assigns a public
`<something>.proxy.rlwy.net:<port>` address for each.

**Caveat:** the classic Tibia protocol embeds the game server's address as a
raw IPv4 address in the character-list packet, not a hostname. Resolve the
TCP proxy hostname to an IP (`nslookup <something>.proxy.rlwy.net`) and set
that IP as the `SERVER_IP` variable (then redeploy). If Railway's proxy IP
changes between deploys, you'll need to update `SERVER_IP` again - for a
short-lived prototype this is usually fine, but if it becomes a problem,
a host with a static IPv4 (e.g. Fly.io with `fly ips allocate-v4`) is more
stable for this protocol.

## 4. First login / creating a GM account

TFS has no built-in signup UI. For testing, insert an account directly via
Railway's MySQL service -> **Data** tab (or any MySQL client using the
connection variables from step 1):

```sql
INSERT INTO accounts (name, password, email, type)
VALUES ('1', SHA1('your-password'), 'you@example.com', 5); -- type 5 = GM/admin

INSERT INTO players (name, account_id, group_id, vocation, sex, town_id, looktype, x, y, z)
VALUES ('Tester', LAST_INSERT_ID(), 5, 0, 1, 1, 128, 1000, 1000, 7);
```

Adjust `x, y, z` to a valid position on your map, and `group_id` per your
`groups.xml` (5 is typically "God"/GM). Login with account name `1` and the
password you hashed above.

## 5. Connecting

Point any TFS-compatible client (native OTClient, or the OTClientV8 web build
once deployed) at `SERVER_IP` and the game port (`7172`'s mapped port).
Use `!campaignphase` in-game (GM only) to verify the campaign scripts loaded -
see [`data/scripts/campaign/README.md`](data/scripts/campaign/README.md) for
the full list of new systems, NPCs, and commands.
