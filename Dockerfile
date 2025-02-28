# Stage 1: Composer (for optimized builds)
FROM composer:latest AS composer

# Stage 2: PHP (final working image)
FROM php:8.2-cli


WORKDIR /var/www/html

# Create a simple PHP page
RUN echo '<?php echo "Your app is running...(configure your project)";' > index.php



# Set the working directory
WORKDIR /app

# Copy composer from the first stage
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev unzip \
    && docker-php-ext-install pdo pdo_mysql

# Copy application files
COPY . /app

# Install Laravel dependencies
RUN composer install --no-scripts --no-autoloader && \
    composer dump-autoload --no-scripts --no-dev --optimize

# Expose port for the application
EXPOSE 8000






# Expose port 8000
EXPOSE 8000

# Start PHP built-in server on port 8000
CMD php -S 0.0.0.0:8000 -t /var/www/html