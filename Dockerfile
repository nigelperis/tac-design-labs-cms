FROM node:20-alpine3.20 as builder
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1 py3-setuptools
RUN npm i -g pnpm@8.10.2 
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}
RUN pnpm install -g node-gyp
WORKDIR /app

# PACKAGE INSTALATION
COPY package.json pnpm-lock.yaml ./
RUN pnpm i --prod

# CODE BUILD
COPY . .
RUN pnpm run build





