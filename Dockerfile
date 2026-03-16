FROM node:22-alpine

WORKDIR /usr/src/app

# Copy manifests first for better caching
COPY package*.json ./

# Install only production deps, reproducibly
RUN npm ci --only=production --ignore-scripts

# Copy the rest of the app
COPY . .

# Drop privileges
USER node

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:5000/ >/dev/null || exit 1

CMD ["npm", "start"]