FROM nextcloud:apache

RUN wget -q https://github.com/nextcloud/calendar/releases/download/v1.5.3/calendar.tar.gz -P /var/www/nextcloud/apps
RUN tar -zxf /var/www/nextcloud/apps/calendar.tar.gz -C /var/www/nextcloud/apps
RUN rm /var/www/nextcloud/apps/calendar.tar.gz
RUN sudo -u www-data php /var/www/nextcloud/occ app:enable calendar