/// <reference types="@cloudflare/workers-types" />

import type { Sandbox } from '@cloudflare/sandbox';

declare global {
  interface Env {
    Sandbox: DurableObjectNamespace<Sandbox>;
    ANTHROPIC_API_KEY?: string;
    OPENAI_API_KEY?: string;
    CLAWDBOT_GATEWAY_TOKEN?: string;
    TELEGRAM_BOT_TOKEN?: string;
    TELEGRAM_DM_POLICY?: string;
    DISCORD_BOT_TOKEN?: string;
    DISCORD_DM_POLICY?: string;
    SLACK_BOT_TOKEN?: string;
    SLACK_APP_TOKEN?: string;
  }
}

export {};
