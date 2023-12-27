# Vaultwarden Auto-Deploy on Fly.io

This project enables the automatic deployment of Vaultwarden (formerly known as Bitwarden_RS) on the Fly.io platform. It also includes features like automatic backups to GitHub Releases and secure access via Cloudflare Tunnel.

## Features

- **Auto-Deployment**: Vaultwarden is automatically deployed on the Fly.io platform, making it easy to run your own self-hosted password manager.

- **Automatic Backups**: Backups of your Vaultwarden data and SQL are each day created and stored on GitHub Releases, ensuring the safety of your data.

- **Auto delete old release files**: Github action automatic delete old release files older that set days.

- **Cloudflare Tunnel**: Cloudflare Tunnel is used to provide secure and encrypted access to your Vaultwarden instance.

- **Auto-Download**: This project automatically downloads the latest versions of the following components:
  - Vaultwarden Web Vault
  - Overmind
  - Supercron

## Dependencies

This project relies on the following tools and libraries:

- [Fly.io](https://fly.io/): A platform for deploying applications globally.

- [Vaultwarden](https://github.com/dani-garcia/vaultwarden): A community-driven fork of Bitwarden_RS, a password manager compatible with the Bitwarden platform.

- [GitHub](https://github.com/): Hosting for your code, including GitHub Releases for backups.

- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps): A secure and scalable way to connect applications to the internet.

- [Supercron](https://github.com/aptible/supercronic): A crontab-compatible job runner for running scheduled tasks.

- [Overmind](https://github.com/DarthSim/overmind): A process manager for Procfile-based applications.

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
   - TOKEN (Github tokken to download file from repo releases and release to Github)

6. Update 'scripts/restore.sh and backup-data-fly.sh' with your name/repo/tag.

7. Deploy the project to Fly.io using the provided deployment script.

8. Enjoy the automatic deployment, backups, and auto-downloading of dependencies for your Vaultwarden instance!

9. To manual backup in your ssh console ./backup-data.sh

10. To restore data in your ssh console use ./restore.sh backup-10-22-22.tar.gz.gpg (name of file witch restore from releases)

11. If need save releases more that 3 days edit in /.github/workflows/clear-old-releases.yml the "$CURRENT_DATE - 3 days" to other day amouth.

## Configuration

You can find configuration options and settings in the respective files and directories within this repository. Make sure to review and adjust them according to your needs.

## Acknowledgments

Special thanks to the creators and maintainers of the tools and libraries that make this project possible:

- [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps) for the secure connection.

- [Supercron](https://github.com/aptible/supercronic) for scheduled tasks.

- [Overmind](https://github.com/DarthSim/overmind) for process management.

## License

This project is licensed under the [MIT License](LICENSE) - see the [LICENSE](LICENSE) file for details.

## Author

- [MartinatorTime](https://github.com/MartinatorTime)

Feel free to reach out with any questions, issues, or suggestions!