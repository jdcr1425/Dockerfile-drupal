FROM ubuntu


MAINTAINER Juan David Casseres 

RUN apt update

#Paso 1 instalar apache

RUN apt-get install apache2 -y
#para saber si el server esta funcionando, necesitaremos la ip publica
# de nuestro servidor ip route y la abrimos en nuestro navegador > http:**ip

RUN a2enmod rewrite

#Paso 2 Instalar MySQL

RUN echo "mysql-server-5.1 mysql-server/root_password password your_mysql_root_password" | debconf-set-selections
RUN echo "mysql-server-5.1 mysql-server/root_password_again password your_mysql_root_password" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server


#Paso 3 Instalar PHP

RUN  apt-get install php mysql-client libapache2-mod-php php-mcrypt php-mysql -y

RUN apt update && apt upgrade

# install the PHP extensions we need

RUN set -ex \

	&& buildDeps=' \
		libpng12-dev \
		libpq-dev \
	' \
	&& apt-get update && apt-get install -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
	&& apt-mark manual \
		libpq5 \
	&& apt-get purge -y --auto-remove $buildDeps


# Establecer la configuración PHP.ini recomendada

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /etc/php/7.0/cli/conf.d/10-opcache.ini


WORKDIR /var/www/html

#Configure PHP memory limit
RUN { \
echo “memory_limit = 256M”; \
} >> /etc/php/7.0/cli/php.ini

#Drupal

#Descargamos drupal desde el sitio web

RUN apt update && apt upgrade

RUN apt install wget -y

RUN wget http://ftp.drupal.org/files/projects/drupal-8.3.7.zip

#Descomprimimos

RUN apt-get install zip unzip

RUN unzip drupal-*.zip


############################################################### 

#Cambiamos ciertos permisos

RUN chown www-data:www-data -R /var/www/html/
RUN chmod -R 755 /var/www/html/

#Configuraciones para drupal 

RUN mkdir -p  /var/www/html/sites/default/files

#RUN chmod 664 /var/www/html/sites/default/settings.php

RUN chown -R :www-data /var/www/html/*

RUN service mysql start


#Para construir nuestra imagen

#sudo docker build -t imagename .

#https://docs.moodle.org/all/es/Guia_de_instalacion_paso-a-paso_para_Ubuntu_16.04


