FROM nextcloud:17-apache

RUN apt-get update && apt-get install -y \
    supervisor \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/log/supervisord /var/run/supervisord  

COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN echo "1 4 * * * php /var/www/html/occ fulltextsearch:index" >> /var/spool/cron/crontabs/www-data

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord"]