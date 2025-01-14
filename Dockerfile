# https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile

# ---- Build ----
FROM node:18-alpine AS builder

ARG NEXT_PUBLIC_PROMPTFOO_REMOTE_API_BASE_URL
ENV NEXT_PUBLIC_PROMPTFOO_REMOTE_API_BASE_URL=${NEXT_PUBLIC_PROMPTFOO_REMOTE_API_BASE_URL}
ENV NEXT_PUBLIC_PROMPTFOO_BUILD_STANDALONE_SERVER=1
ENV NEXT_TELEMETRY_DISABLED 1

WORKDIR /app
COPY . .

# Envars are read in from src/web/nextui/.env.production
RUN echo "*** Building with env vars from .env.production"

RUN npm install

WORKDIR /app/src/web/nextui
RUN npm prune --production

# ---- Final Stage ----
FROM node:18-alpine

ENV NEXT_TELEMETRY_DISABLED 1

WORKDIR /app

COPY --from=builder /app/src/web/nextui/public ./public
COPY --from=builder /app/src/web/nextui/.next/standalone ./
COPY --from=builder /app/src/web/nextui/.next/static ./.next/static

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
