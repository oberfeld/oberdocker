FROM ghcr.io/borgmatic-collective/borgmatic:latest

# Install rclone for S3 sync
RUN apk add --no-cache rclone

# Rclone will use environment variables for configuration
# RCLONE_CONFIG_S3_TYPE, RCLONE_CONFIG_S3_PROVIDER, etc.
