#!/bin/bash
# Startup script for Clawdbot in Cloudflare Sandbox
# This script configures clawdbot from environment variables and starts the gateway

set -e

CONFIG_DIR="/root/.clawdbot"
CONFIG_FILE="$CONFIG_DIR/clawdbot.json"
TEMPLATE_FILE="$CONFIG_DIR/clawdbot.json.template"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Start with the template
if [ -f "$TEMPLATE_FILE" ]; then
    cp "$TEMPLATE_FILE" "$CONFIG_FILE"
else
    # Create minimal config if template doesn't exist
    cat > "$CONFIG_FILE" << 'EOFCONFIG'
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-20250514"
  },
  "gateway": {
    "bind": "0.0.0.0",
    "port": 18789
  }
}
EOFCONFIG
fi

# Use jq to update config with environment variables if available
# We'll use Node.js for JSON manipulation since jq might not be available

node << 'EOFNODE'
const fs = require('fs');
const path = require('path');

const configPath = '/root/.clawdbot/clawdbot.json';
let config = {};

try {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
} catch (e) {
    console.log('Starting with empty config');
}

// Ensure nested objects exist
config.gateway = config.gateway || {};
config.gateway.auth = config.gateway.auth || {};
config.channels = config.channels || {};
config.agent = config.agent || {};

// Gateway configuration
config.gateway.bind = '0.0.0.0';
config.gateway.port = 18789;

// Set gateway token if provided
if (process.env.CLAWDBOT_GATEWAY_TOKEN) {
    config.gateway.auth.mode = 'token';
    config.gateway.auth.token = process.env.CLAWDBOT_GATEWAY_TOKEN;
}

// Anthropic API key
if (process.env.ANTHROPIC_API_KEY) {
    config.agent.anthropicApiKey = process.env.ANTHROPIC_API_KEY;
}

// Telegram configuration
if (process.env.TELEGRAM_BOT_TOKEN) {
    config.channels.telegram = config.channels.telegram || {};
    config.channels.telegram.botToken = process.env.TELEGRAM_BOT_TOKEN;
    config.channels.telegram.enabled = true;
    
    // Set DM policy to open for sandbox use (adjust as needed)
    config.channels.telegram.dm = config.channels.telegram.dm || {};
    config.channels.telegram.dm.policy = process.env.TELEGRAM_DM_POLICY || 'pairing';
}

// Discord configuration
if (process.env.DISCORD_BOT_TOKEN) {
    config.channels.discord = config.channels.discord || {};
    config.channels.discord.token = process.env.DISCORD_BOT_TOKEN;
    config.channels.discord.enabled = true;
    
    config.channels.discord.dm = config.channels.discord.dm || {};
    config.channels.discord.dm.policy = process.env.DISCORD_DM_POLICY || 'pairing';
}

// Slack configuration
if (process.env.SLACK_BOT_TOKEN && process.env.SLACK_APP_TOKEN) {
    config.channels.slack = config.channels.slack || {};
    config.channels.slack.botToken = process.env.SLACK_BOT_TOKEN;
    config.channels.slack.appToken = process.env.SLACK_APP_TOKEN;
    config.channels.slack.enabled = true;
}

// OpenAI API key (for alternative models)
if (process.env.OPENAI_API_KEY) {
    config.agent.openaiApiKey = process.env.OPENAI_API_KEY;
}

// Write updated config
fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
console.log('Configuration updated successfully');
console.log('Config:', JSON.stringify(config, null, 2));
EOFNODE

echo "Starting Clawdbot Gateway..."
echo "Gateway will be available on port 18789"

# Start the gateway (blocking)
exec clawdbot gateway --port 18789 --verbose
