# syntax=docker/dockerfile:1

# 1) Install deps (prod only)
FROM node:22-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# 2) Build (opsional jika ada langkah build)
FROM node:22-alpine AS builder
WORKDIR /app
COPY . .
COPY --from=deps /app/node_modules ./node_modules
# Jika tidak ada langkah build, baris di bawah ini akan tetap sukses
RUN npm run build || echo "no build step"

# 3) Runtime ringan
FROM node:22-alpine AS runner
ENV NODE_ENV=production
WORKDIR /app

# Salin hasil build (atau kode jika tidak ada build step)
COPY --from=builder /app ./

# Zeabur menyediakan PORT (default 8080) — pastikan aplikasi listen ke env ini
ENV PORT=8080
EXPOSE 8080

# Pastikan package.json memiliki "start"
CMD ["npm", "start"]
