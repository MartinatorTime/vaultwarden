FROM vaultwarden/server:latest

ARG INSTALL_OVERMIND=true
ARG INSTALL_SUPERCRONIC=true
ARG INSTALL_CADDY=fasle
ARG INSTALL_B2=false
ARG INSTALL_CLOUDFLARED=true
ARG INSTALL_WEB_VAULT=true
ARG DOMAIN
ARG SMTP_HOST
ARG SMTP_PORT
ARG SMTP_SECURITY
ARG CF_TOKEN

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
    EMAIL_ATTEMPTS_LIMIT=3 \
    EMAIL_TOKEN_SIZE=6 \
    PASSWORD_HINTS_ALLOWED=false \
    LOGIN_RATELIMIT_MAX_BURST=5 \
    LOGIN_RATELIMIT_SECONDS=60 \
    ADMIN_SESSION_LIFETIME=3 \
    DOMAIN="https://${DOMAIN}" \
    DOMAIN_NAME=${DOMAIN} \
    SMTP_HOST=${SMTP_HOST} \
    SMTP_PORT=${SMTP_PORT} \
    SMTP_SECURITY=${SMTP_SECURITY} \
    REQUIRE_DEVICE_EMAIL=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    sqlite3 libnss3-tools libpq5 wget curl tar lsof jq gpg \
    ca-certificates openssl tmux procps rclone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && ln -snf /usr/share/zoneinfo/Europe/Riga /etc/localtime \
    && echo Europe/Riga > /etc/timezone

# Create Procfile
RUN echo "vaultwarden: /start.sh" > /Procfile

# Optimized installation of tools with error handling
RUN set -ex; \
    OVERMIND_VERSION=$(curl -s https://api.github.com/repos/DarthSim/overmind/releases/latest | jq -r '.tag_name'); \
    SUPERCRONIC_VERSION=$(curl -s https://api.github.com/repos/aptible/supercronic/releases/latest | jq -r '.tag_name'); \
    VAULT_VERSION=$(curl -s https://api.github.com/repos/dani-garcia/bw_web_builds/releases/latest | jq -r '.tag_name'); \
    CADDY_VERSION=$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | jq -r '.tag_name'); \
    CLOUDFLARED_VERSION="2024.10.0"; \
    B2_VERSION=$(curl -s "https://api.github.com/repos/Backblaze/B2_Command_Line_Tool/releases/latest" | jq -r '.tag_name'); \
    \
    if [ "$INSTALL_OVERMIND" = "true" ]; then \
        curl -L -o overmind.gz "https://github.com/DarthSim/overmind/releases/download/$OVERMIND_VERSION/overmind-${OVERMIND_VERSION}-linux-amd64.gz" || exit 1; \
        gunzip overmind.gz && chmod +x overmind && mv overmind /usr/local/bin/; \
    fi; \
    \
    if [ "$ISNTALL_SUPERCRONIC" = "true" ]; then \
        curl -L -o /usr/local/bin/supercronic "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" || exit 1; \
        chmod +x /usr/local/bin/supercronic; \
        echo "backup: supercronic /crontab" >> /Procfile; \
    fi; \
    \
    if [ "$INSTALL_WEB_VAULT" = "true" ]; then \
        curl -L -o web-vault.tar.gz "https://github.com/dani-garcia/bw_web_builds/releases/download/${VAULT_VERSION}/bw_web_v${VAULT_VERSION#v}.tar.gz" || exit 1; \
        tar -xzf web-vault.tar.gz -C / ; \
    fi; \
    \
    if [ "$INSTALL_CLOUDFLARED" = "true" ]; then \
        curl -L -o cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/download/$CLOUDFLARED_VERSION/cloudflared-linux-amd64.deb" || exit 1; \
        dpkg -i cloudflared.deb; \
        echo "cf_tunnel: cloudflared tunnel --no-autoupdate run --protocol quic --token "$CF_TOKEN"" >> /Procfile; \
    fi; \
    \
    if [ "$INSTALL_CADDY" = "true" ]; then \
        wget -O caddy.tar.gz "https://github.com/caddyserver/caddy/releases/download/$CADDY_VERSION/caddy_${CADDY_VERSION#v}_linux_amd64.tar.gz" || exit 1; \
        tar -xzf caddy.tar.gz -C /usr/local/bin/ caddy; \
        echo "caddy: caddy run --config /etc/caddy/Caddyfile --adapter caddyfile" >> /Procfile; \
    fi; \
    \
    if [ "$INSTALL_B2" = "true" ]; then \
        curl -L -o /usr/local/bin/b2 "https://github.com/Backblaze/B2_Command_Line_Tool/releases/download/$B2_VERSION/b2-linux" || exit 1; \
        chmod +x /usr/local/bin/b2; \
    fi


# Copy files with correct permissions (use a single COPY if your Docker version supports it)
COPY --chmod=755 config/crontab /crontab
COPY --chmod=755 scripts/backup-rclone-cloudflare.sh /backup-rclone-cloudflare.sh
COPY --chmod=755 scripts/backup-data-github.sh /backup-data-github.sh
COPY --chmod=755 scripts/restore-data-github.sh /restore-data-github.sh
COPY --chmod=755 entrypoint.sh /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]

CMD ["overmind", "start"]