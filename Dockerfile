FROM vaultwarden/server:latest

# You can choose what to install with vaultwarden
ARG INSTALL_SUPERCRONIC=true
ARG INSTALL_CADDY=true
ARG BACKUP_BACKBLAZE_R2=false
ARG SYNC_DATA_CLOUDFLARE_R2=true
ARG INSTALL_CLOUDFLARED=true
ARG INSTALL_LAST_WEB_VAULT=true
ARG BACKUP_RCLONE_R2=true
ARG FAIL2BAN=true
ARG KEEP_ALIVE=true

# Set up timezone
ARG TIMEZONE=Europe/Riga

ENV ROCKET_PROFILE=release \
    ROCKET_ADDRESS=0.0.0.0 \
    ROCKET_PORT=8080 \
    ROCKET_WORKERS=20 \
    SSL_CERT_DIR=/etc/ssl/certs \
    EMERGENCY_ACCESS_ALLOWED=true \
    EXTENDED_LOGGING=true \
    LOG_FILE=/data/vaultwarden.log \
    LOG_LEVEL=info \
    ICON_SERVICE=google \
    IP_HEADER=X-Forwarded-For \
    ORG_CREATION_USERS=all \
    ORG_EVENTS_ENABLED=false \
    ORG_GROUPS_ENABLED=false \
    PUSH_ENABLED=true \
    #Comment this two bellow if you use Bitwarden's official push server
    PUSH_RELAY_URI=https://api.bitwarden.eu \
    PUSH_IDENTITY_URI=https://identity.bitwarden.eu \
    RELOAD_TEMPLATES=false \
    SENDS_ALLOWED=true \
    SHOW_PASSWORD_HINT=false \
    SIGNUPS_ALLOWED=false \
    SIGNUPS_VERIFY=true \
    USE_SYSLOG=false \
    WEBSOCKET_ENABLED=true \
    WEB_VAULT_ENABLED=true \
    DATABASE_MAX_CONNS=5 \
    DB_CONNECTION_RETRIES=15 \
    ICON_DOWNLOAD_TIMEOUT=20 \
    ICON_BLACKLIST_NON_GLOBAL_IPS=true \
    EMAIL_CHANGE_ALLOWED=true \
    EMAIL_ATTEMPTS_LIMIT=30 \
    EMAIL_TOKEN_SIZE=6 \
    PASSWORD_HINTS_ALLOWED=false \
    LOGIN_RATELIMIT_MAX_BURST=5 \
    LOGIN_RATELIMIT_SECONDS=60 \
    ADMIN_SESSION_LIFETIME=3 \
    REQUIRE_DEVICE_EMAIL=false \
    R2_DATA_SYNC_LOG=false \
    SYNC_DATA_CLOUDFLARE_R2=${SYNC_DATA_CLOUDFLARE_R2} \
    FAIL2BAN=${FAIL2BAN} \
    FLY_SWAP=false \
    OVERMIND_DAEMONIZE=0 \
    PRIVILEGED=true \
    OVERMIND_AUTO_RESTART=all \
    CFAPITOKEN=${CFAPITOKEN} \
    CFZONEID=${CFZONEID} \
    KEEP_ALIVE=${KEEP_ALIVE}

# Install dependencies and set timezone
RUN apt-get update && apt-get install -y --no-install-recommends \
    sqlite3 libnss3-tools libpq5 wget curl tar lsof jq gpg gnupg2 postgresql \
    ca-certificates openssl tmux procps rclone fail2ban \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo ${TIMEZONE} > /etc/timezone

# Create Procfile for overmind
RUN echo "vaultwarden: /start.sh" > /Procfile

# Optimized installation of tools with error handling
RUN set -ex; \
    OVERMIND_VERSION=$(curl -s https://api.github.com/repos/DarthSim/overmind/releases/latest | jq -r '.tag_name'); \
    SUPERCRONIC_VERSION=$(curl -s https://api.github.com/repos/aptible/supercronic/releases/latest | jq -r '.tag_name'); \
    VAULT_VERSION=$(curl -s https://api.github.com/repos/dani-garcia/bw_web_builds/releases/latest | jq -r '.tag_name'); \
    CADDY_VERSION=$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | jq -r '.tag_name'); \
    CLOUDFLARED_VERSION=$(curl -s https://api.github.com/repos/cloudflare/cloudflared/releases/latest | jq -r '.tag_name'); \
    B2_VERSION=$(curl -s "https://api.github.com/repos/Backblaze/B2_Command_Line_Tool/releases/latest" | jq -r '.tag_name'); \
    \
    curl -L -o overmind.gz "https://github.com/DarthSim/overmind/releases/download/$OVERMIND_VERSION/overmind-${OVERMIND_VERSION}-linux-amd64.gz" || exit 1; \
    gunzip overmind.gz && chmod +x overmind && mv overmind /usr/local/bin/; \
    \
    if [ "$INSTALL_SUPERCRONIC" = "true" ]; then \
        curl -L -o /usr/local/bin/supercronic "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" || exit 1; \
        chmod +x /usr/local/bin/supercronic; \
        echo "backup: supercronic /crontab" >> /Procfile; \
        echo "1 0 * * * /backup-data-github.sh" > /crontab; \
    fi; \
    \
    if [ "$BACKUP_RCLONE_R2" = "true" ]; then \
        echo "5 0 * * * /backup-r2-rclone.sh" >> /crontab; \
    fi; \
    \
    if [ "$INSTALL_LAST_WEB_VAULT" = "true" ]; then \
        curl -L -o web-vault.tar.gz "https://github.com/dani-garcia/bw_web_builds/releases/download/${VAULT_VERSION}/bw_web_v${VAULT_VERSION#v}.tar.gz" || exit 1; \
        tar -xzf web-vault.tar.gz -C / ; \
    fi; \
    \
    if [ "$INSTALL_CLOUDFLARED" = "true" ]; then \
        curl -L -o cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/download/$CLOUDFLARED_VERSION/cloudflared-linux-amd64.deb" || exit 1; \
        dpkg -i cloudflared.deb; \
        echo "cf_tunnel: /start_cloudflared.sh" >> /Procfile; \
    fi; \
    \
    if [ "$INSTALL_CADDY" = "true" ]; then \
        wget -O caddy.tar.gz "https://github.com/caddyserver/caddy/releases/download/$CADDY_VERSION/caddy_${CADDY_VERSION#v}_linux_amd64.tar.gz" || exit 1; \
        tar -xzf caddy.tar.gz -C /usr/local/bin/ caddy; \
        echo "caddy: caddy run --config /etc/caddy/Caddyfile --adapter caddyfile" >> /Procfile; \
    fi; \
    \
    if [ "$SYNC_DATA_CLOUDFLARE_R2" = "true" ]; then \
        echo "data-sync: /sync-r2-rclone.sh" >> /Procfile; \
    fi; \
    \
    if [ "$KEEP_ALIVE" = "true" ]; then \
    echo "keep-alive: /keep-alive.sh" >> /Procfile; \
    fi; \
    \
    if [ "$BACKUP_BACKBLAZE_R2" = "true" ]; then \
        curl -L -o /usr/local/bin/b2 "https://github.com/Backblaze/B2_Command_Line_Tool/releases/download/$B2_VERSION/b2-linux" || exit 1; \
        chmod +x /usr/local/bin/b2; \
        echo "3 0 * * * /backup-r2-backblaze.sh" >> /crontab; \
    fi; \
    if [ "$FAIL2BAN" = "true" ]; then \
        echo "fail2ban: fail2ban-server -f -x start" >> /Procfile; \
    fi

# Copy files to docker
COPY scripts/*.sh /
COPY Caddyfile /etc/caddy/Caddyfile
COPY fail2ban/jail.d /etc/fail2ban/jail.d
COPY fail2ban/action.d /etc/fail2ban/action.d
RUN chmod +x /etc/fail2ban/action.d/action-ban-cloudflare.conf
COPY fail2ban/filter.d /etc/fail2ban/filter.d

# Chmod the scripts
RUN chmod +x /*.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["overmind", "start"]
