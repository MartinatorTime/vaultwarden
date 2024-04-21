# Vaultwarden Auto-Deploy on Fly.io

This project enables the automatic deployment of Vaultwarden (formerly known as Bitwarden_RS) on the Fly.io platform. It also includes features like automatic backups to GitHub Releases and secure access via Cloudflare Tunnel.


## Features

- **Auto-Deployment**: Vaultwarden is automatically deployed on the Fly.io platform, making it easy to run your own self-hosted password manager.

- **Automatic Backups**: Backups of your Vaultwarden data and SQL are each day created and stored on GitHub Releases, Backblaze R2 Bucket and Cloudflare R2, ensuring the safety of your data.

- **Auto delete old release files**: Github action automatically deletes old release files older than set days.

- **Cloudflare Tunnel**: Cloudflare Tunnel is used to provide secure and encrypted access to your Vaultwarden instance.

- **Auto-Download**: This project automatically downloads the latest versions of the following components:
  - Vaultwarden
  - Vaultwarden Web Vault
  - Overmind
  - Supercron
  - Caddy
  - Cloudflared

- **Caddy Server**: Caddy is used as a reverse proxy and web server to serve your Vaultwarden instance. It simplifies the deployment process by handling HTTPS and other web server tasks, making your setup more efficient and secure.

## Dependencies

This project relies on the following tools and libraries:

- [Fly.io](https://fly.io/): A platform for deploying applications globally.

- [Vaultwarden](https://github.com/dani-garcia/vaultwarden): A community-driven fork of Bitwarden_RS, a password manager compatible with the Bitwarden platform.

- [GitHub](https://github.com/): Hosting for your code, including GitHub Releases for backups.

- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps): A secure and scalable way to connect applications to the internet.

- [Supercron](https://github.com/aptible/supercronic): A crontab-compatible job runner for running scheduled tasks.

- [Overmind](https://github.com/DarthSim/overmind): A process manager for Procfile-based applications.

- [Caddy](https://caddyserver.com/): A powerful, enterprise-ready, open-source web server with automatic HTTPS written in Go.

## Getting Started

1. Sign up for an account on [Fly.io](https://fly.io/) if you don't already have one.

2. FORK this repository.

3. Configure your Fly.io and GitHub settings to match your project requirements.

4. Update `Dockerfile.fly` with your ENVS, domain names and values

5. Add these GITHUB secrets:
   - ADMIN_TOKEN
   - DATABASE (URL of the database)
   - FLY_API_TOKEN
   - FLY_APP (Fly.io App name)
   - PASS (a passphrase used to encrypt and decrypt backup files)
   - PUSH_INSTALLATION_ID (for more information, refer to the Vaultwarden repository)
   - PUSH_INSTALLATION_KEY
   - B2_APPLICATION_KEY_ID (Backblaze B2 Application Key ID)
   - B2_APPLICATION_KEY (Backblaze B2 Application Key)
   - B2_BUCKET (Backblaze B2 Bucket Name)
   - SMTP_HOST (The hostname of your SMTP server. For example, if you are using Gmail, this would be `smtp.gmail.com`)
   - SMTP_PORT (The port number to use when connecting to the SMTP server. Common ports include `465` for SSL/TLS connections and `587` for STARTTLS connections)
   - SMTP_SECURITY (The security protocol to use when connecting to the SMTP server. Set this to `force_tls` to force TLS encryption)
   - SMTP_USERNAME (Your username/gmail for the SMTP service)
   - SMTP_PASSWORD (Your password for the SMTP service)
   - CF_ACCESS_KEY (Cloudflare R2 Access Key ID)
   - CF_ACCESS_KEY_SECRET (Cloudflare R2 Access Key Secret)
   - CF_R2_ENDPOINT (Cloudflare R2 Endpoint)
   - DOMAIN (Your domain like vault.my.com)
   - TOKEN (Your Github Token to upload backup to releases)


6. Update 'scripts/restore-data-github.sh and backup-data-github.sh' with your name/repo/tag.

7. Deploy the project to Fly.io using the provided deployment script.

8. Enjoy the automatic deployment, backups, and auto-downloading of dependencies for your Vaultwarden instance!

9. To manual backup in your ssh console use on of backup scripts.

10. To restore data in your ssh console use ./restore-data-github.sh backup-10-22-22.tar.gz.gpg (name of file witch restore from Github releases)

11. If need save releases more that 3 days edit in /.github/workflows/clear-old-releases.yml the "$CURRENT_DATE - 3 days" to other day amouth.

## Configuration

You can find configuration options and settings in the respective files and directories within this repository. Make sure to review and adjust them according to your needs.

## Acknowledgments

Special thanks to the creators and maintainers of the tools and libraries that make this project possible:

- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps) for the secure connection.

- [Supercron](https://github.com/aptible/supercronic) for scheduled tasks.

- [Overmind](https://github.com/DarthSim/overmind) for process management.

- [Caddy](https://caddyserver.com/) for serving as a powerful, enterprise-ready, open-source web server with automatic HTTPS.

- [Vaultwarden](https://github.com/dani-garcia/vaultwarden) for nice port of Bitwarden.

## License

This project is licensed under the [MIT License](LICENSE) - see the [LICENSE](LICENSE) file for details.

## Author

- [MartinatorTime](https://github.com/MartinatorTime)

Feel free to reach out with any questions, issues, or suggestions!