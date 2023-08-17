FROM arm64v8/php:7.4-apache
ENV DEBIAN_FRONTEND=noninteractive

# Install components
RUN apt-get update -y && apt-get install -y \
		curl \
		default-mysql-client \
		g++ \
		git-core \
		libcurl4-openssl-dev \
		libgd-dev \
		libfreetype6-dev \
		libicu-dev \
		libldap2-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
		libtidy-dev \
		libxslt-dev \
		nano \
		openssh-client \
		unzip \
		zip \
		zlib1g-dev \
		--no-install-recommends && \
		rm -r /var/lib/apt/lists/*

# Install PHP Extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure intl && \
	docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
	docker-php-ext-configure ldap --with-libdir=lib/$(uname -m)-linux-gnu/ && \
	# pecl install mcrypt-1.0.3 && \
	docker-php-ext-install -j$(nproc) \
		bcmath \
		gd \
		intl \
		ldap \
		mysqli \
		pdo \
		pdo_mysql \
		soap \
		tidy \
		xsl

# Apache + xdebug configuration
RUN { \
                echo "<VirtualHost *:80>"; \
                echo "  DocumentRoot /var/www/html"; \
                echo "  LogLevel warn"; \
                echo "  ErrorLog /var/log/apache2/error.log"; \
                echo "  CustomLog /var/log/apache2/access.log combined"; \
                echo "  ServerSignature Off"; \
                echo "  <Directory /var/www/html>"; \
                echo "    Options +FollowSymLinks"; \
                echo "    Options -ExecCGI -Includes -Indexes"; \
                echo "    AllowOverride all"; \
                echo; \
                echo "    Require all granted"; \
                echo "  </Directory>"; \
                echo "  <LocationMatch assets/>"; \
                echo "    php_flag engine off"; \
                echo "  </LocationMatch>"; \
                echo; \
                echo "  IncludeOptional sites-available/000-default.local*"; \
                echo "</VirtualHost>"; \
	} | tee /etc/apache2/sites-available/000-default.conf

RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && \
	echo "date.timezone = America/Chicago" > /usr/local/etc/php/conf.d/timezone.ini && \
	a2enmod rewrite expires remoteip cgid && \
	usermod -u 1000 www-data && \
	usermod -G staff www-data


# Install Xdebug
RUN pecl install xdebug-3.1.5 && \
	docker-php-ext-enable xdebug && \
	sed -i '1 a xdebug.start_with_request=yes' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	sed -i '1 a xdebug.discover_client_host=1 ' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	sed -i '1 a xdebug.client_port=9003' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	sed -i '1 a xdebug.client_host=127.0.0.1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	sed -i '1 a xdebug.mode=debug,profile' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    #php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer


# Install SSPAK
RUN curl -sS https://silverstripe.github.io/sspak/install | php -- /usr/local/bin


EXPOSE 80
EXPOSE 443
CMD ["apache2-foreground"]
