# 使用PHP 5.6 Apache基础镜像
FROM php:5.6-apache

# 设置工作目录
WORKDIR /var/www/html

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install zip

# 安装Redis扩展
RUN pecl install redis-4.3.0 \
    && docker-php-ext-enable redis

# 配置Apache
RUN a2enmod rewrite

# 复制项目文件
COPY . /var/www/html/

# 设置目录权限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 暴露端口
EXPOSE 80

# 启动Apache
CMD ["apache2-foreground"] 