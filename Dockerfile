FROM php:5.6-apache

# 更新源为archive.debian.org
RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
    -e 's|security.debian.org|archive.debian.org/debian-security|g' \
    -e '/stretch-updates/d' /etc/apt/sources.list

# Update repository URLs and install dependencies
RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
    -e 's|security.debian.org|archive.debian.org/debian-security|g' \
    -e '/stretch-updates/d' /etc/apt/sources.list \
    && apt-get update --allow-insecure-repositories \
    && apt-get install -y --allow-unauthenticated \
        libzip-dev \
        zip \
        unzip \
    && docker-php-ext-install zip

# Install Redis extension
RUN pecl install redis-4.3.0 \
    && docker-php-ext-enable redis

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy application files
COPY . /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Configure Apache for URL rewriting
RUN echo '<Directory /var/www/html>\n\
    AllowOverride All\n\
    </Directory>' >> /etc/apache2/apache2.conf

# Create .htaccess file with rewrite rules
RUN echo 'RewriteEngine On\n\
RewriteRule ^(content|admin|key|login)$ /$1.php [L]' > /var/www/html/.htaccess

EXPOSE 80

CMD ["apache2-foreground"] 