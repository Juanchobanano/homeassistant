# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a home server configuration repository. It manages a stack of self-hosted services via Docker Compose, deployed on a Linux host at `/home/juanchobanano/`. The repo tracks config files and the `docker-compose.yml` that defines all services.

## Key files

- `docker-compose.yml` — the authoritative definition of all running services (production, deployed on the Linux server)
- `config/configuration.yaml` — Home Assistant config (local dev reference; production volume mounts from `/home/juanchobanano/homeassistant`)
- `mosquitto/config/mosquitto.conf` — Mosquitto MQTT broker config

## Services

| Service | Image | Port(s) | Notes |
|---|---|---|---|
| homeassistant | `ghcr.io/home-assistant/home-assistant:stable` | host network | TZ=America/Bogota |
| code-server | `linuxserver/code-server` | 9444 | Web VS Code over the HA config dir |
| n8n | `n8nio/n8n:next` | internal network | Workflow automation (WhatsApp bot, CRM sync). Accessed via Cloudflare Tunnel at `https://n8n.<domain>/` |
| openclaw | `ghcr.io/openclaw/openclaw:latest` | 18789, 18791 | LLM gateway (needs `ANTROPIC_API_KEY`, `OPENAI_API_KEY` env vars) |
| cloudflared | `cloudflare/cloudflared:latest` | none (outbound tunnel) | Cloudflare Tunnel connector; exposes n8n securely to the internet |
| twenty-server | `twentycrm/twenty:latest` | 3001 | Twenty CRM server (API + UI). Also: `twenty-worker`, `twenty-db` (pg16), `twenty-redis` |
| unifi | `jacobalberty/unifi:latest` | host network | Network controller; data at `/home/juanchobanano/unifi` |
| mosquitto | `eclipse-mosquitto:2.0` | 1883, 9001 | MQTT broker (commented out in root compose, active in `config/`) |

## Deployment

Changes are deployed by copying files to the server and running Docker Compose there. There is no CI/CD pipeline. The root `docker-compose.yml` is what runs in production; `config/configuration.yaml` is a local reference copy.

## Environment variables

The root `docker-compose.yml` references these env vars (must be set on the server):
- `ANTROPIC_API_KEY` — for openclaw
- `OPENAI_API_KEY` — for openclaw
- `TUNNEL_TOKEN` — Cloudflare Tunnel token (from Cloudflare Zero Trust dashboard)
- `PG_DATABASE_USER` — Twenty CRM DB user (default: `twenty`)
- `PG_DATABASE_PASSWORD` — Twenty CRM DB password
- `PG_DATABASE_NAME` — Twenty CRM DB name (default: `default`)
- `TWENTY_APP_SECRET` — Twenty CRM app secret (generate with `openssl rand -hex 32`)
- `TWENTY_ENCRYPTION_KEY` — Twenty CRM encryption key
- `TWENTY_FALLBACK_ENCRYPTION_KEY` — Twenty CRM fallback encryption key
- `SERVER_URL` — Twenty CRM public URL (e.g., `http://192.168.2.44:3001`)
