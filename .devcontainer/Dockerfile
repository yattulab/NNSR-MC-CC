FROM JohnnyMorganz/StyLua:2.5.2 AS stylua

FROM mcr.microsoft.com/devcontainers/base:noble

COPY --from=stylua /stylua /usr/local/bin/stylua

RUN apt-get update \
    && apt-get install -y \
        git \
        curl \
        lua5.2 \
    && rm -rf /var/lib/apt/lists/*