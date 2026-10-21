
FROM python:3.10.8-slim@sha256:49749648f4426b31b20fca55ad854caa55ff59dc604f2f76b57d814e0a47c181 AS base

FROM base AS builder

# Fix the archived Debian Bullseye security repository
RUN set -eux; \
    if [ -f /etc/apt/sources.list ]; then \
        sed -i 's|deb.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list; \
    fi; \
    if [ -d /etc/apt/sources.list.d ]; then \
        grep -rl 'deb.debian.org/debian-security' /etc/apt/sources.list.d 2>/dev/null \
          | xargs -r sed -i 's|deb.debian.org/debian-security|archive.debian.org/debian-security|g'; \
    fi; \
    apt-get -o Acquire::Check-Valid-Until=false update; \
    apt-get install -y --no-install-recommends wget g++; \
    rm -rf /var/lib/apt/lists/*

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
ENV ENABLE_PROFILER=1

WORKDIR /email_server

COPY --from=builder /usr/local/lib/python3.10/ /usr/local/lib/python3.10/
COPY . .

EXPOSE 8080

ENTRYPOINT ["python", "email_server.py"]

FROM without-grpc-health-probe-bin

COPY --from=builder /bin/grpc_health_probe /bin/grpc_health_probe
