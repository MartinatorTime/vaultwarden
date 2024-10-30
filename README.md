# Vaultwarden Auto-Deploy on Fly.io

This project automates the deployment and maintenance of Vaultwarden (formerly Bitwarden_RS) on Fly.io, featuring automatic backups, secure access via Cloudflare Tunnel, and streamlined dependency management.

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
5. **GitHub Secrets:** Add the following secrets to your GitHub repository:
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
    *  `CF_TOKEN` (Cloudflare Tunnel token -- see `start_cloudflared.sh`)

6. **Backup Scripts:** Update `scripts/restore-data-github.sh` and `scripts/backup-data-github.sh` with your GitHub repository information (username, repo name).
7. **Deploy:** Use `flyctl deploy` to deploy to Fly.io (refer to `deploy-fly.yml` for example usage).

## Backing Up and Restoring

* **Manual Backup:** SSH into your Fly.io instance and execute the relevant backup script in the `scripts` directory.
* **Restore from GitHub:**  Use `./restore-data-github.sh <backup_filename>` (e.g., `./restore-data-github.sh backup-10-22-22.tar.gz.gpg`) within your Fly.io instance.
* **Release Pruning:**  Adjust the retention period in `.github/workflows/clear-old-releases.yml` if needed.


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

