# Clawdbot in Cloudflare Sandbox

Run [Clawdbot](https://clawd.bot/) personal AI assistant in a Cloudflare Sandbox container.

## What is this?

This project runs Clawdbot's Gateway (the control plane for the personal AI assistant) inside a Cloudflare Sandbox container. You interact with it via:

- **WebChat**: Built-in web chat interface at the root URL
- **Control UI**: Gateway dashboard for configuration and monitoring
- **Channels**: Optional integrations with Telegram, Discord, Slack, etc.

## Prerequisites

- [Node.js](https://nodejs.org/) >= 18
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/)
- An Anthropic API key (or other supported provider)
- Cloudflare account with Workers and Containers access

## Quick Start

### 1. Install dependencies

```bash
npm install
```

### 2. Configure secrets

Set your API keys as Wrangler secrets:

```bash
# Required: Anthropic API key for Claude models
wrangler secret put ANTHROPIC_API_KEY

# Optional: Protect gateway access with a token
wrangler secret put CLAWDBOT_GATEWAY_TOKEN
```

### 3. Deploy

```bash
npm run deploy
```

### 4. Access your Clawdbot

Open the deployed URL in your browser. You'll see the Clawdbot Control UI where you can:

- Use WebChat to interact with your assistant
- Monitor sessions and usage
- Configure settings

## Configuration

### Required Secrets

| Secret | Description |
|--------|-------------|
| `ANTHROPIC_API_KEY` | Your Anthropic API key for Claude models |

### Optional Secrets

| Secret | Description |
|--------|-------------|
| `CLAWDBOT_GATEWAY_TOKEN` | Token to protect gateway access |
| `OPENAI_API_KEY` | OpenAI API key (for alternative models) |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `TELEGRAM_DM_POLICY` | DM policy: `pairing` (default) or `open` |
| `DISCORD_BOT_TOKEN` | Discord bot token |
| `DISCORD_DM_POLICY` | DM policy: `pairing` (default) or `open` |
| `SLACK_BOT_TOKEN` | Slack bot token |
| `SLACK_APP_TOKEN` | Slack app token |

### Setting Secrets

```bash
# Example: Add Telegram bot
wrangler secret put TELEGRAM_BOT_TOKEN
# Enter your bot token when prompted

# Example: Set DM policy to open (not recommended for production)
wrangler secret put TELEGRAM_DM_POLICY
# Enter: open
```

## Channel Setup

### Telegram

1. Create a bot via [@BotFather](https://t.me/botfather)
2. Copy the bot token
3. Set the secret: `wrangler secret put TELEGRAM_BOT_TOKEN`
4. Redeploy: `npm run deploy`

Default DM policy is `pairing` - unknown users will receive a pairing code that you need to approve.

### Discord

1. Create an application at [Discord Developer Portal](https://discord.com/developers/applications)
2. Create a bot and copy the token
3. Set the secret: `wrangler secret put DISCORD_BOT_TOKEN`
4. Invite the bot to your server with appropriate permissions
5. Redeploy: `npm run deploy`

### Slack

1. Create a Slack app at [api.slack.com](https://api.slack.com/apps)
2. Enable Socket Mode and get an App-Level Token
3. Add Bot Token Scopes and install to workspace
4. Set secrets:
   ```bash
   wrangler secret put SLACK_BOT_TOKEN
   wrangler secret put SLACK_APP_TOKEN
   ```
5. Redeploy: `npm run deploy`

## Local Development

```bash
npm run dev
```

This starts a local development server. Note that container features may have limitations in local dev mode.

## Architecture

```
Browser / Chat App
       │
       ▼
┌─────────────────────────────────────┐
│     Cloudflare Worker (index.ts)    │
│  - Proxies requests to Clawdbot     │
│  - Injects secrets as env vars      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     Cloudflare Sandbox Container    │
│  ┌───────────────────────────────┐  │
│  │     Clawdbot Gateway          │  │
│  │  - Control UI (Web Dashboard) │  │
│  │  - WebChat                    │  │
│  │  - Channel Connectors         │  │
│  │  - Agent Runtime              │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Endpoints

| Path | Description |
|------|-------------|
| `/` | Clawdbot Control UI / WebChat |
| `/health` | Gateway health check |
| `/sandbox-health` | Sandbox wrapper health check |
| `/ws` | WebSocket endpoint for real-time communication |

## Customization

### Modify Default Configuration

Edit `clawdbot.json.template` to change default settings:

```json
{
  "agent": {
    "model": "anthropic/claude-sonnet-4-20250514",
    "name": "Your Bot Name",
    "persona": "Custom persona description..."
  }
}
```

### Change the Model

Set a different default model in the template:

- `anthropic/claude-opus-4-5` - Most capable
- `anthropic/claude-sonnet-4-20250514` - Good balance (default)
- `anthropic/claude-haiku-4-5` - Fastest/cheapest

## Troubleshooting

### Gateway fails to start

1. Check that `ANTHROPIC_API_KEY` is set: `wrangler secret list`
2. Check Worker logs: `wrangler tail`

### Channels not connecting

1. Verify the token is set correctly
2. Check that the bot has appropriate permissions
3. For Telegram/Discord: ensure the bot is added to the chat/server

### WebSocket issues

The Control UI uses WebSockets. If you're behind a proxy, ensure WebSocket connections are allowed.

## Security Notes

- **DM Pairing**: By default, unknown DMs require approval via a pairing code. This prevents unauthorized access.
- **Gateway Token**: Set `CLAWDBOT_GATEWAY_TOKEN` to protect the web UI from unauthorized access.
- **Channel Policies**: Review DM policies before setting to `open` in production.

## Links

- [Clawdbot Documentation](https://docs.clawd.bot)
- [Clawdbot GitHub](https://github.com/clawdbot/clawdbot)
- [Cloudflare Sandbox SDK](https://github.com/cloudflare/sandbox-sdk)

## License

MIT
