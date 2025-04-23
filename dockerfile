# Use official PHP image with Apache
FROM php:8.2-apache

# Set environment variables
ENV APACHE_DOCUMENT_ROOT=/var/www/html \
    PORT=10000

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_mysql \
    mysqli \
    gd \
    zip \
    opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache for Render.com
RUN { \
    echo "Listen ${PORT}"; \
    echo "<VirtualHost *:${PORT}>"; \
    echo "  ServerAdmin webmaster@localhost"; \
    echo "  DocumentRoot \${APACHE_DOCUMENT_ROOT}"; \
    echo "  <Directory \${APACHE_DOCUMENT_ROOT}>"; \
    echo "    Options Indexes FollowSymLinks"; \
    echo "    AllowOverride All"; \
    echo "    Require all granted"; \
    echo "  </Directory>"; \
    echo "  ErrorLog \${APACHE_LOG_DIR}/error.log"; \
    echo "  CustomLog \${APACHE_LOG_DIR}/access.log combined"; \
    echo "</VirtualHost>"; \
} > /etc/apache2/sites-available/000-default.conf

# Copy application files
COPY --chown=www-data:www-data . ${APACHE_DOCUMENT_ROOT}/

# Set proper permissions
RUN chmod -R 755 ${APACHE_DOCUMENT_ROOT} && \
    chmod 644 ${APACHE_DOCUMENT_ROOT}/users.json ${APACHE_DOCUMENT_ROOT}/error.log || true

# Set working directory
WORKDIR ${APACHE_DOCUMENT_ROOT}

# Expose the port
EXPOSE ${PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:${PORT}/ || exit 1
