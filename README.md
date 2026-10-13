# Element Self-Hosted

A production-ready, air-gapped deployment of [Element](https://element.io) (Matrix) with integrated [Jitsi](https://jitsi.org) for group video/audio calls — fully offline capable, no internet dependency.

## Stack

| Service | Image | Purpose |
|---|---|---|
| Synapse | `matrixdotorg/synapse` | Matrix homeserver |
| Element Web | `vectorim/element-web` | Web client |
| Jitsi Meet | `jitsi/web` + `prosody` + `jicofo` + `jvb` | Video/audio calls |
| PostgreSQL | `postgres:16-alpine` | Database |
| OpenResty | `openresty/openresty:alpine` | Reverse proxy |
| coturn | `coturn/coturn` | TURN server for WebRTC |

## Features

- **Fully offline** — no internet required after initial setup
- **No federation** — isolated from public Matrix network
- **No lobby/moderator** in Jitsi — join calls directly
- **Docker security hardened** — `no-new-privileges`, `cap_drop: ALL`, `pids_limit`
- **Internal CA** — self-signed SSL with proper SAN
- **Internal DNS** — dnsmasq resolves domain locally
- **Closed registration** — admin-only user creation

## Quick Start

### 1. Prerequisites

```bash
# Ubuntu 22.04+
apt install docker.io docker-compose-v2 dnsmasq openssl
```

### 2. Configure

```bash
git clone https://github.com/pingfun1995/element-selfhosted
cd element-selfhosted
cp .env.example .env
# Edit .env with your values
nano .env
```

### 3. Generate SSL Certificate

```bash
bash scripts/gen-cert.sh
```

### 4. Initialize Synapse

```bash
docker run --rm \
  -v ./data/synapse:/data \
  -e SYNAPSE_SERVER_NAME=${DOMAIN} \
  -e SYNAPSE_REPORT_STATS=no \
  matrixdotorg/synapse:latest generate
```

### 5. Start

```bash
docker compose up -d
```

### 6. Create first admin user

```bash
docker exec -it element-synapse-1 \
  register_new_matrix_user -u admin -p yourpassword -a \
  -c /data/homeserver.yaml http://localhost:8008
```

## Ports

| Port | Service |
|---|---|
| 443 | Element Web + Matrix API |
| 8444 | Synapse Admin panel |
| 8448 | Jitsi Meet |
| 3478 | TURN (UDP/TCP) |
| 10000 | Jitsi JVB media (UDP) |

## Client Setup

1. Install **Element** app (Android/iOS/Desktop)
2. Install the CA certificate on your device (`https://DOMAIN/tara-ca.crt`)
3. Set DNS to point to `SERVER_IP`
4. Connect to `https://DOMAIN`

## Security

- All containers run with `no-new-privileges` and minimal capabilities
- SSL via internal CA (valid 10 years)
- Matrix federation disabled
- External integrations disabled
- User registration closed

## License

MIT
