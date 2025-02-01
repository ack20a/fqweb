FROM php:5.6-apache

# Configure Debian Stretch archive repositories
RUN echo "deb http://archive.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list \
    && echo "deb http://archive.debian.org/debian-security/ stretch/updates main contrib non-free" >> /etc/apt/sources.list

# Install dependencies
RUN apt-get update --allow-insecure-repositories \
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