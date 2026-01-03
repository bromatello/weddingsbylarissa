# Node-based Dockerfile to serve the static site using the 'serve' package
# - Uses a lightweight Node Alpine image
# - Installs runtime dependencies and runs `npm start` which uses `serve`

FROM node:20-alpine

WORKDIR /usr/src/app

# Install a tiny utility for healthcheck and then install production deps
RUN apk add --no-cache wget

# Copy package manifest and install production dependencies
COPY package.json ./
RUN npm install --production --no-audit --no-fund

# Copy site files
COPY . .

# Run as non-root for safety
RUN chown -R node:node /usr/src/app
USER node

EXPOSE 5000

# Basic healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:5000/ >/dev/null || exit 1

CMD ["npm", "start"]
