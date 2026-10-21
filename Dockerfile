
# Copyright 2020 Google LLC
# Licensed under the Apache License, Version 2.0

FROM python:3.10-slim-bookworm AS base

FROM base AS builder

# Install required system packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        g++ \
    && rm -rf /var/lib/apt/lists/*

# Download the gRPC health probe
ENV GRPC_HEALTH_PROBE_VERSION=v0.4.18

RUN wget -qO /bin/grpc_health_probe \
    "https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64" \
    && chmod +x /bin/grpc_health_probe

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM base AS without-grpc-health-probe-bin

ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /recommendationservice

# Copy installed Python packages
COPY --from=builder /usr/local/lib/python3.10/ /usr/local/lib/python3.10/

# Copy application files
COPY . .

EXPOSE 8080

ENTRYPOINT ["python", "recommendation_server.py"]

FROM without-grpc-health-probe-bin

COPY --from=builder /bin/grpc_health_probe /bin/grpc_health_probe
