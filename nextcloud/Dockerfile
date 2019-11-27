FROM nextcloud:16.0.5-apache

RUN apt-get update \
  && apt-get install -y supervisor \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/log/supervisord /var/run/supervisord  \
  && echo "1 4 * * * php /var/www/html/occ fulltextsearch:index" >> /var/spool/cron/crontabs/www-data 

COPY supervisord.conf /etc/supervisor/supervisord.conf

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord"]