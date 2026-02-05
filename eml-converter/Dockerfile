FROM eclipse-temurin:21-jre-noble

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wkhtmltopdf \
        inotify-tools \
        curl \
        ca-certificates \
    && curl -L -o /opt/emailconverter.jar \
        https://github.com/nickrussler/email-to-pdf-converter/releases/download/3.0.0/emailconverter-3.0.0-all.jar \
    && chmod 644 /opt/emailconverter.jar \
    && apt-get purge -y curl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 convert-eml.sh /usr/local/bin/convert-eml.sh

# Run as www-data (UID 33) to match Nextcloud file ownership
USER 33:33

ENTRYPOINT ["/usr/local/bin/convert-eml.sh"]
