FROM php:8.2-apache

RUN docker-php-ext-install pdo pdo_mysql

COPY gestion-produits/php/www/ /var/www/html/

RUN chown -R www-data:www-data /var/www/html/uploads \
    && chmod 755 /var/www/html/uploads

EXPOSE 80
