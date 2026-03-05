# Docker notes — weddingsbylarissa

This repo includes a small Docker setup to run the static site using nginx.

Files added:
- `Dockerfile` — builds an nginx image that serves the site's files.
- `.docker/nginx.conf` — small nginx config (cache and security headers).
- `.dockerignore` — excludes local files from Docker build context.
- `docker-compose.yml` — convenient local development setup (maps port 8080).

Quick commands
- Build image:
  docker build -t weddingsbylarissa .

- Run container:
  docker run --rm -p 8080:80 weddingsbylarissa

- Use docker-compose (development, mounts local files read-only):
  docker-compose up --build

Node-based image (alternative)
- You can build and run a Node-based image that uses the `serve` static server (listens on port 5000):
  - Build: docker build -f Dockerfile.node -t weddingsbylarissa-node .
  - Run: docker run --rm -p 8080:5000 weddingsbylarissa-node
  - Or with Compose: docker-compose -f docker-compose.node.yml up --build

Notes
- The container serves the static files exactly as in your repo; changes on disk are visible when using `docker-compose` (because of the volume).
- Google Maps and other third-party scripts will still load if they are reachable from the container's network (they are external requests).
- If you prefer a different server (Caddy, httpd) or an automated deployment (GH Pages, GitHub Actions), tell me and I can add that too.
