# Stage 1: Composer (for dependencies)
FROM composer:latest AS composer

# Stage 2: PHP (final image)
FROM php:8.2-cli

WORKDIR /app

# Install required dependencies and Node.js
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    curl \
    gnupg \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && node --version \
    && npm --version

# Copy composer from composer stage
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . /app

# Install dependencies
RUN composer install --no-scripts --no-autoloader && \
    composer dump-autoload --no-scripts --no-dev --optimize

# Create a default index file
WORKDIR /var/www/html
RUN echo '<?php echo "Your app is running...(configure your project)";' > index.php

# Expose port 8000
EXPOSE 8000

WORKDIR /app
# Start PHP built-in server
CMD php -S 0.0.0.0:8000 -t /var/www/html