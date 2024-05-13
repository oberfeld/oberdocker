FROM nextcloud:28-apache

RUN apt-get update && apt-get install -y \
    supervisor libmagickcore-6.q16-6-extra \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/log/supervisord /var/run/supervisord  

COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN echo "1 4 * * * php /var/www/html/occ fulltextsearch:index" >> /var/spool/cron/crontabs/www-data

ENV NEXTCLOUD_UPDATE=1

CMD ["/usr/bin/supervisord"]
