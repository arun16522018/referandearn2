# Use official PHP image with Apache
FROM php:8.2-apache

# Install required extensions
RUN apt-get update && apt-get install -y \
    && docker-php-ext-install pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module
RUN a2enmod rewrite

# Update Apache to listen on port 10000 (Render requirement)
RUN sed -i 's/80/10000/' /etc/apache2/ports.conf && \
    sed -i 's/80/10000/' /etc/apache2/sites-enabled/000-default.conf

# Copy files to container
COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod 644 /var/www/html/users.json /var/www/html/error.log || true

# Set working directory
WORKDIR /var/www/html

# Expose Render's required port
EXPOSE 10000

# Start Apache
CMD ["apache2-foreground"]
