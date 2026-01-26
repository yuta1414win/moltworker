FROM docker.io/cloudflare/sandbox:0.7.0

# Install Node.js 22 (required by clawdbot)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version

# Install pnpm globally
RUN npm install -g pnpm

# Install clawdbot globally
RUN npm install -g clawdbot@latest \
    && clawdbot --version

# Create clawdbot directories
RUN mkdir -p /root/.clawdbot \
    && mkdir -p /root/clawd \
    && mkdir -p /root/clawd/skills

# Copy startup script
COPY start-clawdbot.sh /usr/local/bin/start-clawdbot.sh
RUN chmod +x /usr/local/bin/start-clawdbot.sh

# Copy default configuration template
COPY clawdbot.json.template /root/.clawdbot/clawdbot.json.template

# Set working directory
WORKDIR /root/clawd

# Expose the gateway port
EXPOSE 18789
