FROM node:20-alpine3.20 as builder
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1 py3-setuptools
RUN npm install --global corepack@latest
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable
RUN corepack enable pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
RUN pnpm install -g node-gyp
WORKDIR /build

# PACKAGE INSTALATION
COPY package.json pnpm-lock.yaml ./
RUN pnpm i --prod
ENV PATH="/build/node_modules/.bin:$PATH"


# CODE BUILD
WORKDIR /build/outputs
COPY . .
RUN pnpm run build


# Runner stage
FROM node:20-alpine3.20 as runner
RUN apk add --no-cache vips-dev
RUN npm install --global -y corepack@latest
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable
RUN corepack enable pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
WORKDIR /app
COPY --from=builder /build/node_modules ./node_modules
ENV PATH="/app/node_modules/.bin:$PATH"
WORKDIR /app/outputs
COPY --from=builder /build/outputs ./

# Rutime configuration
RUN chown -R node:node /app/outputs
EXPOSE 1337
ENTRYPOINT ["pnpm","start"]











