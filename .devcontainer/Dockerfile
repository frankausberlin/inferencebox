FROM node:18-alpine

RUN apk add --no-cache git

WORKDIR /workspaces/dsbase

COPY package*.json ./
RUN npm install

EXPOSE 3000