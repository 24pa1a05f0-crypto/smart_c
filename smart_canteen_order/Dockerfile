# ==============================================================================
# Multi-stage Dockerfile for Smart Canteen Ordering System (Flutter Web + Nginx)
# Compatible with Render, Railway, Google Cloud Run, and AWS ECS.
# ==============================================================================

# Stage 1: Build Flutter Web App
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec and resolve dependencies
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy full source tree
COPY . .

# Build optimized production release of Flutter Web
RUN flutter build web --release --pwa-strategy=none

# Stage 2: High Performance Nginx Production Server
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built Flutter web artifacts into nginx web root
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Render exposes the port in the $PORT environment variable
ENV PORT=80
EXPOSE 80

# Substitute PORT in nginx.conf if provided by Render and start nginx
CMD sh -c "sed -i 's/listen 80;/listen '${PORT:-80}';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"

