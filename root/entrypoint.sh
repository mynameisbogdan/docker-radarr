#!/usr/bin/env bash

exec \
    /app/radarr/bin/Radarr \
        --nobrowser \
        --data=/config \
        "$@"
