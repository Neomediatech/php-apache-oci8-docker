FROM debian:jessie as builder

MAINTAINER Dario <docker-dario@neomediatech.it>

# install oracle client
COPY /oracle-11/ /tmp/

RUN apt-get update && \
    apt-get -y install unzip && \
    mkdir -p /tmp/instantclient && \
    unzip /tmp/instantclient-basic-linuxAMD64-10.1.0.5.0-20060519 -d /tmp/instantclient/ && \
    unzip /tmp/instantclient-sqlplus-linuxAMD64-10.1.0.5.0-20060519 -d /tmp/instantclient/ && \  
    unzip /tmp/instantclient-sdk-linuxAMD64-10.1.0.5.0-20060519 -d /tmp/instantclient/ 

FROM debian:jessie
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Rome
ENV LD_LIBRARY_PATH /usr/local/instantclient/

RUN mkdir -p /usr/local/instantclient
COPY --from=builder /tmp/instantclient/instantclient10_1 /usr/local/instantclient

RUN echo $TZ > /etc/timezone && \ 
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install apache2 php5 libapache2-mod-php5 php5-dev php-pear php5-curl curl libaio1 unzip tzdata && \ 
    ln -s /usr/local/instantclient/libclntsh.so.10.1 /usr/local/instantclient/libclntsh.so && \
    ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
    echo "instantclient,/usr/local/instantclient" | pecl install -f oci8-2.0.8 && \
    echo "extension=oci8.so" > /etc/php5/apache2/conf.d/30-oci8.ini && \
    a2enmod rewrite && \
    dpkg-reconfigure -f noninteractive tzdata && \ 
    apt-get -y purge '.*-dev' && \
    apt-get -y autoremove --purge && \
    rm -rf /var/lib/apt/lists*

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set up the Apache2 environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

# Run Apache2 in Foreground
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
