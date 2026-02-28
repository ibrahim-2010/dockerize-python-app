# ============================================
# Dockerize Python App Challenge
# ============================================
#
# YOUR TASK: Create a production-ready Dockerfile
#
# Requirements:
# 1. Use multi-stage build (builder + final stages)
# 2. Final image must be under 200MB
# 3. Run as non-root user (security)
# 4. Include a health check
# 5. Use python:3.11-slim for the final image
#
# Hints:
# - Stage 1 (builder): Install dependencies
# - Stage 2 (final): Copy only what's needed
# - Use --prefix=/install with pip to control where packages go
# - Create a user with: RUN useradd --create-home appuser
# - Health check can use Python urllib (curl not in slim image)
#
# ============================================

# TODO: Implement your Dockerfile here!
#
# Delete everything below and write your own.
# See README.md for step-by-step hints.

# This is a BROKEN starter - it works but has problems:
# - Image is too big (~1GB)
# - Runs as root (insecure)
# - No health check
# - No multi-stage build

# ============================================
# Stage 1: Builder
# ============================================
FROM python:3.11 AS builder

WORKDIR /app

# Install dependencies to a specific location
COPY requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# ============================================
# Stage 2: Final (Production)
# ============================================
FROM python:3.11-alpine

# Alpine uses different user creation command
RUN adduser -D -s /bin/sh appuser

WORKDIR /app

COPY --from=builder /install /usr/local

COPY --chown=appuser:appuser src/ ./src/

ENV FLASK_APP=src/app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000
ENV PYTHONUNBUFFERED=1

USER appuser
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["python", "src/app.py"]