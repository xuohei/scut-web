FROM alpine as inotify
RUN apk add --update wget php7 php7-dev build-base && \
    wget https://pecl.php.net/get/inotify-3.0.0.tgz -O /inotify-3.0.0.tgz && \
    tar xf /inotify-3.0.0.tgz && cd /inotify-3.0.0 && \
    phpize && ./configure && \
    make && make install

FROM alpine
COPY --from=inotify /usr/lib/php7/modules/inotify.so /usr/lib/php7/modules/
RUN apk --update add --no-cache php7 php7-redis redis bzip2 && \
    echo "extension = inotify.so" >> /etc/php7/php.ini && \
    echo "daemonize yes" >> /etc/redis.conf && \
    echo "redis-server /etc/redis.conf" > /init.sh && \
    echo "php /etc/archive/prog/format.php &" >> /init.sh && \
    echo "/usr/sbin/crond" >> /init.sh && \
    echo "read -n 1" >> /init.sh && \
    sed -i '$i\0\t0\t*\t*\t*\t/etc/archive/prog/scutweb.sh' /var/spool/cron/crontabs/root && \
    sed -i '$i\0\t0\t*\t*\t*\t/etc/archive/prog/route.sh' /var/spool/cron/crontabs/root
CMD ["sh","init.sh"]
