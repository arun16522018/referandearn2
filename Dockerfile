# Use official PHP image with Apache
FROM php:8.2-apache

# Install required extensions
RUN apt-get update && apt-get install -y \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy files to container
COPY . /var/www/html/

# Set proper permissions for data files
RUN chown -R www-data:www-data /var/www/html/users.json /var/www/html/error.log
RUN chmod 644 /var/www/html/users.json /var/www/html/error.log

# Set working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80