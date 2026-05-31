FROM php:8.2-apache

# pdo_pgsql au lieu de pdo_mysql — nécessite libpq-dev (client PostgreSQL)
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

# Étape 1 : copie de TOUS les fichiers PHP originaux (identique à la variante MySQL)
COPY gestion-produits/php/www/ /var/www/html/

# Étape 2 : écrasement des 3 fichiers incompatibles avec PostgreSQL (stratégie ADR-005)
COPY docker/app-pgsql/overrides/ /var/www/html/

RUN chown -R www-data:www-data /var/www/html/uploads \
    && chmod 755 /var/www/html/uploads

EXPOSE 80
