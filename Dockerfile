FROM vaultwarden/server:latest

ARG DOMAIN

# Set Env
ENV ROCKET_PROFILE="release" \
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
    DOMAIN=https://${DOMAIN} \
    DOMAIN_NAME=${DOMAIN} \
    SMTP_HOST=${SMTP_HOST} \
    SMTP_PORT=${SMTP_PORT} \
    SMTP_SECURITY=${SMTP_SECURITY} \
    REQUIRE_DEVICE_EMAIL=true

VOLUME /
# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    sqlite3 \
    libnss3-tools \
    libpq5 \
    wget \
    curl \
    tar \
    lsof \
    jq \
    gpg \
    ca-certificates \
    openssl \
    tmux \
    procps \
    rclone && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the timezone to Riga at runtime
RUN ln -snf /usr/share/zoneinfo/Europe/Riga /etc/localtime && echo Europe/Riga > /etc/timezone

# Install Backblaze (latest release)
#RUN wget https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux -O b2 \
#    && mv b2 /usr/local/bin/ \
#    && chmod +x /usr/local/bin/b2

# Download and extract Overmind (latest release)
RUN OVERMIND_VERSION=$(curl -s https://api.github.com/repos/DarthSim/overmind/releases/latest | jq -r '.tag_name') \
    && wget -O overmind.gz "https://github.com/DarthSim/overmind/releases/download/$OVERMIND_VERSION/overmind-${OVERMIND_VERSION}-linux-amd64.gz" \
    && gunzip overmind.gz \
    && chmod +x overmind \
    && mv overmind /usr/local/bin/

# Download and install SuperCronic for linux-amd64 (latest release)
RUN SUPERCRONIC_VERSION=$(curl -s https://api.github.com/repos/aptible/supercronic/releases/latest | jq -r '.tag_name') \
    && wget -O /usr/local/bin/supercronic "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" \
    && chmod +x /usr/local/bin/supercronic

# Download and install Last Web-Vault (latest release)
RUN VAULT_VERSION=$(curl -s https://api.github.com/repos/dani-garcia/bw_web_builds/releases/latest | jq -r '.tag_name') \
    && rm -rf /web-vault \
    && wget -O web-vault.tar.gz "https://github.com/dani-garcia/bw_web_builds/releases/download/${VAULT_VERSION}/bw_web_v${VAULT_VERSION#v}.tar.gz" \
    && tar -xzf web-vault.tar.gz -C /

# Download and extract Caddy (latest release)
#RUN CADDY_VERSION=$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | jq -r '.tag_name') \
#    && wget -O caddy.tar.gz "https://github.com/caddyserver/caddy/releases/download/$CADDY_VERSION/caddy_${CADDY_VERSION#v}_linux_amd64.tar.gz" \
#    && tar -xzf caddy.tar.gz -C /usr/local/bin/ caddy

# Install cloudflared tunnel (2024.10.0)
RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/download/2024.10.0/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared.deb

# Delete downloaded archives
RUN rm -rf overmind.gz web-vault.tar.gz cloudflared.deb caddy.tar.gz
    
# Copy files to docker
COPY config/crontab /crontab
COPY config/Procfile /Procfile
#COPY scripts/backup-r2-backblaze.sh /backup-r2-backblaze.sh
COPY scripts/backup-rclone-cloudflare.sh /backup-rclone-cloudflare.sh
COPY scripts/backup-data-github.sh /backup-data-github.sh
COPY scripts/restore-data-github.sh /restore-data-github.sh
#COPY config/Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /entrypoint.sh

# Chmod the scripts
#RUN chmod +x /backup-r2-backblaze.sh
RUN chmod +x /backup-rclone-cloudflare.sh
RUN chmod +x /backup-data-github.sh
RUN chmod +x /restore-data-github.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint script as the entrypoint for the container
ENTRYPOINT ["/entrypoint.sh"]

# Start Overmind
CMD ["overmind", "start"]
