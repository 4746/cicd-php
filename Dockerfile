FROM php:8.1-fpm

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/composer
ENV COMPOSER_MEMORY_LIMIT=-1
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV EDITOR=/usr/bin/nano

# Install dev dependencies
RUN apt-get update -y && apt-get upgrade -y

# Install production dependencies
RUN apt-get install -y --no-install-recommends \
    bash \
    wget \
    curl \
    g++ \
    gcc \
    ssh \
    openssh-client \
    libicu-dev \
    git \
    imagemagick \
    libxml2-dev \
    libpng-dev \
    libc-dev \
    mc \
    nano \
    unzip \
    rsync \
    libzip-dev \
    libmagickwand-dev \
    libldap2-dev \
    libfreetype6-dev \
    libfreetype6


# Install PECL and PEAR extensions
RUN pecl install imagick \
    && pecl install -o -f redis \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

RUN docker-php-ext-install \
    pdo_mysql \
    pcntl \
    xml \
    gd \
    zip \
    bcmath \
    exif \
    gd \
    ldap \
    soap \
    intl

RUN docker-php-ext-configure gd \
    && docker-php-ext-configure zip \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap_r.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap_r.a /usr/lib/libldap_r.a \
    && docker-php-ext-configure ldap

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get install -y ca-certificates gnupg && mkdir -p /etc/apt/keyrings &&  \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&  \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list &&  \
    echo "Package: nodejs" >> /etc/apt/preferences.d/preferences &&  \
    echo "Pin: origin deb.nodesource.com" >> /etc/apt/preferences.d/preferences &&  \
    echo "Pin-Priority: 1001" >> /etc/apt/preferences.d/preferences &&  \
    apt-get update && apt-get install -y nodejs

RUN composer global require deployer/deployer \
    && composer global require friendsofphp/php-cs-fixer \
    && echo "alias dep='/composer/vendor/bin/dep'" >> ~/.bashrc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && php -m

# Setup working directory
WORKDIR /var/www