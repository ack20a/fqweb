FROM php:5.6-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
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