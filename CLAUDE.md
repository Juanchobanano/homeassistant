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
| n8n | `n8nio/n8n:next` | 5678 | Workflow automation |
| openclaw | `ghcr.io/openclaw/openclaw:latest` | 18789, 18791 | LLM gateway (needs `ANTROPIC_API_KEY`, `OPENAI_API_KEY` env vars) |
| unifi | `jacobalberty/unifi:latest` | host network | Network controller; data at `/home/juanchobanano/unifi` |
| mosquitto | `eclipse-mosquitto:2.0` | 1883, 9001 | MQTT broker (commented out in root compose, active in `config/`) |

## Deployment

Changes are deployed by copying files to the server and running Docker Compose there. There is no CI/CD pipeline. The root `docker-compose.yml` is what runs in production; `config/configuration.yaml` is a local reference copy.

## Environment variables

The root `docker-compose.yml` references these env vars (must be set on the server):
- `ANTROPIC_API_KEY` — for openclaw
- `OPENAI_API_KEY` — for openclaw
