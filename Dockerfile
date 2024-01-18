FROM ubuntu:latest

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install some initial utilities
RUN apt-get update && apt-get install -y \
    tzdata \
    software-properties-common \
    curl \
    apt-transport-https \
    lsb-release \
    ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Add Ondřej Surý's PHP PPA for PHP 8.2
RUN add-apt-repository ppa:ondrej/php

# Add NodeSource Node.js 18.x repo
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# Install packages
RUN apt-get update && apt-get install -y \
    nginx \
    zip \
    unzip \
    nano \
    git \
    nodejs \
    php8.2-fpm \
    php8.2-xml \
    php8.2-cli \
    php8.2-mbstring \
    php8.2-mysql \
    php8.2-imagick \
    php8.2-curl \
    php8.2-sqlite3 \
    php8.2-intl \
    php8.2-gd \
    php-pear \
    php8.2-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN pecl install xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy nginx configuration
COPY nginx.conf /etc/nginx/sites-available/default

# Set working directory
WORKDIR /var/www/html

# Copy application source code
COPY . /var/www/html

# Install Composer dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader \
    && composer update

# Set permissions
RUN chown -R www-data:www-data storage/ \
    && php artisan key:generate

# Expose port 80
EXPOSE 80

# Start services
CMD service php8.2-fpm start && nginx -g 'daemon off;'
