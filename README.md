# Vaultwarden Auto-Deploy on Fly.io

This project automates the deployment and maintenance of Vaultwarden (formerly Bitwarden_RS) on Fly.io or ther platforms, featuring automatic backups, secure access via Cloudflare Tunnel, and streamlined dependency management.

## Features

* **Automated Deployment:** Effortlessly deploy Vaultwarden to Fly.io for self-hosting your password manager.
* **Automatic Backups:** Secure daily backups to GitHub Releases, Backblaze B2, and Cloudflare R2.
* **Automated Backup Pruning:** GitHub Actions automatically deletes old release files.
* **Cloudflare Tunnel:** Secure and encrypted access to your Vaultwarden instance.
* **Automatic Dependency Updates:**  Downloads the latest versions of:
    * Vaultwarden
    * Vaultwarden Web Vault
    * Overmind
    * Supercronic
    * Caddy
    * Cloudflared
* **Caddy Reverse Proxy:**  Handles HTTPS and other web server tasks for improved security and efficiency.
* **Auto sync with rclone R2** Change entrypoit and sync-r2-rclone.sh with your endpoint data
* **Auto sync check every 60 sec** if /data folder and file are modified, if yes, it sync with r2.

## Dependencies

* [Fly.io](https://fly.io/)
* [Vaultwarden](https://github.com/dani-garcia/vaultwarden)
* [GitHub](https://github.com/)
* [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps)
* [Supercronic](https://github.com/aptible/supercronic)
* [Overmind](https://github.com/DarthSim/overmind)
* [Caddy](https://caddyserver.com/)


## Getting Started

1. **Fork this Repository:**  Click the "Fork" button.
2. **Fly.io Account:** Sign up for a [Fly.io](https://fly.io/) account if you don't have one.
3. **Configure Settings:** Adjust Fly.io and GitHub settings to match your needs.
4. **Environment Variables:** Update the `Dockerfile` with necessary environment variables (see below).
    * **General Settings:**
        * `TIMEZONE` (e.g., `Europe/Riga`)
    * **Vaultwarden Settings:**
        * `ROCKET_PROFILE` (e.g., `release`)
        * `ROCKET_ADDRESS` (e.g., `0.0.0.0`)
        * `ROCKET_PORT` (e.g., `8080`)
        * `ROCKET_WORKERS` (e.g., `20`)
        * `SSL_CERT_DIR` (e.g., `/etc/ssl/certs`)
        * `EMERGENCY_ACCESS_ALLOWED` (e.g., `true`)
        * `EXTENDED_LOGGING` (e.g., `true`)
        * `LOG_FILE` (e.g., `/data/vaultwarden.log`)
        * `LOG_LEVEL` (e.g., `info`)
        * `ICON_SERVICE` (e.g., `google`)
        * `IP_HEADER` (e.g., `X-Forwarded-For`)
        * `ORG_CREATION_USERS` (e.g., `all`)
        * `ORG_EVENTS_ENABLED` (e.g., `false`)
        * `ORG_GROUPS_ENABLED` (e.g., `false`)
        * `PUSH_ENABLED` (e.g., `true`)
        * `RELOAD_TEMPLATES` (e.g., `false`)
        * `SENDS_ALLOWED` (e.g., `true`)
        * `SHOW_PASSWORD_HINT` (e.g., `false`)
        * `SIGNUPS_ALLOWED` (e.g., `false`)
        * `SIGNUPS_VERIFY` (e.g., `true`)
        * `USE_SYSLOG` (e.g., `false`)
        * `WEBSOCKET_ENABLED` (e.g., `true`)
        * `WEB_VAULT_ENABLED` (e.g., `true`)
        * `DATABASE_MAX_CONNS` (e.g., `5`)
        * `DB_CONNECTION_RETRIES` (e.g., `15`)
        * `ICON_DOWNLOAD_TIMEOUT` (e.g., `20`)
        * `ICON_BLACKLIST_NON_GLOBAL_IPS` (e.g., `true`)
        *  `EMAIL_CHANGE_ALLOWED` (e.g., `true`)
        * `EMAIL_ATTEMPTS_LIMIT` (e.g., `3`)
        * `EMAIL_TOKEN_SIZE` (e.g., `6`)
        * `PASSWORD_HINTS_ALLOWED` (e.g., `false`)
        * `LOGIN_RATELIMIT_MAX_BURST` (e.g., `5`)
        * `LOGIN_RATELIMIT_SECONDS` (e.g., `60`)
        * `ADMIN_SESSION_LIFETIME` (e.g., `3`)
        * `REQUIRE_DEVICE_EMAIL` (e.g., `false`)
    * **Feature Flags:**
        * `SYNC_DATA_CLOUDFLARE_R2` = true (To enable sync with r2)
        * `R2_DATA_SYNC_LOG` = false (Show output log with sync of skip sync)
        * `BACKUP_BACKBLAZE_R2` = true (Enable backup data folder to blackblaze R2)
        * `INSTALL_CADDY` = true (Install caddy within container)
        * `INSTALL_CLOUDFLARED` = true (Install cloudflared tunnel)
        * `INSTALL_LAST_WEB_VAULT` = true (Install lastest web vault version)
        * `INSTALL_SUPERCRONIC` = true (Install cron to every day making backup to github releases)
        * `BACKUP_RCLONE_R2` = true (If superchonic is activated it backup one time in day to your desired r2 endpoint)
        * `FLY_SWAP` = true (Create swap on fly.io)

5. **GitHub Secrets:** Add the following secrets to your GitHub repository or to your provider dashboard:
    * `ADMIN_TOKEN`
    * `DATABASE` (Database URL)
    * `FLY_API_TOKEN`
    * `FLY_APP` (Fly.io app name)
    * `USERNAME` (GitHub username for backups)
    * `PASS` (Passphrase to encrypt/decrypt backups)
    * `PUSH_INSTALLATION_ID` (Refer to Vaultwarden documentation)
    * `PUSH_INSTALLATION_KEY`
    * `B2_APPLICATION_KEY_ID`
    * `B2_APPLICATION_KEY`
    * `B2_BUCKET`
    * `SMTP_HOST` (e.g., `smtp.gmail.com`)
    * `SMTP_PORT` (e.g., `465` or `587`)
    * `SMTP_SECURITY` (e.g., `force_tls`)
    * `SMTP_USERNAME`
    * `SMTP_PASSWORD`
    * `CF_ACCESS_KEY` (Cloudflare R2 Access Key ID)
    * `CF_ACCESS_KEY_SECRET` (Cloudflare R2 Access Key Secret)
    * `CF_R2_ENDPOINT` (Cloudflare R2 Endpoint)
    * `DOMAIN` (Your domain, e.g., `vault.my.com`)
    * `TOKEN` (GitHub token for uploading backups)
    * `CF_TOKEN` (Cloudflare Tunnel token -- see `start_cloudflared.sh`)

6. **Backup Scripts:** Update `scripts/restore-data-github.sh` and `scripts/backup-data-github.sh` with your GitHub repository information (username, repo name).
    * In `backup-data-github.sh` change to your details:
        * `REPO_NAME="vaultwarden"`
        * `TAG="FLY-DATA"`
        * `USERNAME="MartinatorTime"`
7. **Deploy:** Use `flyctl deploy` to deploy to Fly.io (refer to `deploy-fly.yml` for example usage).

## Backing Up and Restoring

* **Manual Backup:** SSH into your Fly.io instance and execute the relevant backup script in the `scripts` directory.
* **Restore from GitHub:**  Use `./restore-data-github.sh <backup_filename>` (e.g., `./restore-data-github.sh backup-10-22-22.tar.gz.gpg`) within your Fly.io instance.
* **Release Pruning:**  Adjust the retention period in `.github/workflows/clear-old-releases.yml` if needed.

## Deployment on Koyeb or Northflank

This project can also be deployed on Koyeb or Northflank. The general process is similar to deploying on Fly.io, but you will need to adjust the configuration to match the specific requirements of each platform.

Refer to the respective platform's documentation for detailed instructions:

* [Koyeb Documentation](https://www.koyeb.com/docs)
* [Northflank Documentation](https://northflank.com/docs)

## Configuration

Refer to the respective files (e.g., `Dockerfile`, `fly.toml`, `Caddyfile`, scripts in the `scripts` directory) for configuration options.


## Acknowledgements

* [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps)
* [Supercronic](https://github.com/aptible/supercronic)
* [Overmind](https://github.com/DarthSim/overmind)
* [Caddy](https://caddyserver.com/)
* [Vaultwarden](https://github.com/dani-garcia/vaultwarden)

## License

[MIT License](LICENSE)


## Author

[MartinatorTime](https://github.com/MartinatorTime)
