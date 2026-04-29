# ── Stage: Production image ──────────────────────────────────────────
FROM nginx:alpine

# Metadata labels — good practice, shows up in Docker Hub
LABEL maintainer="Umm-e-Hani"
LABEL description="Static HTML site served by Nginx — built via Jenkins CI/CD"
LABEL version="1.0"

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy our static website files
COPY src/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Healthcheck — Docker checks if container is healthy every 30s
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

# Start nginx in foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]
