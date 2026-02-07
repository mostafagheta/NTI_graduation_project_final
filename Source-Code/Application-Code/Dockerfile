# ===== Build Stage =====
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --silent || npm i --silent

COPY . .
RUN npm run build

# ===== Runtime Stage (least privilege) =====
FROM nginx:1.25-alpine

# nginx on alpine runs as root by default for binding 80; still small official image
# If you want least privileged, you'd need custom port + user, or rootless nginx.
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD wget -qO- http://localhost/ >/dev/null 2>&1 || exit 1
