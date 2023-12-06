FROM nextcloud:REPLACETAG
RUN apt-get update && apt-get install -y \
  supervisor \
  unzip \
  gnupg2 \
  cron \
  libc-client-dev libkrb5-dev \
  smbclient \
  git-core \
#  composer \
  wget nodejs npm cmake libx11-dev libbz2-dev \
#  libopenblas-base \
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install imap \
  && docker-php-ext-configure bz2 \
  && docker-php-ext-install bz2 \
  && rm -rf /var/lib/apt/lists/* 

# Enable repo and install dlib (for face recognition)
RUN echo "deb https://repo.delellis.com.ar bullseye bullseye" > /etc/apt/sources.list.d/20-pdlib.list \
  && wget -qO - https://repo.delellis.com.ar/repo.gpg.key | apt-key add -
RUN apt update \
  && apt install -y libdlib-dev \
  && rm -rf /var/lib/apt/lists/* 

# Install pdlib extension
#RUN wget https://github.com/goodspb/pdlib/archive/master.zip \
#  && mkdir -p /usr/src/php/ext/ \
#  && unzip -d /usr/src/php/ext/ master.zip \
#  && rm master.zip
#RUN docker-php-ext-install pdlib-master


#COPY --from=builder /usr/local/lib/libdlib.so* /usr/local/lib/

# If is necesary take the php extention folder uncommenting the next line
# RUN php -i | grep extension_dir
#COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-20200930/pdlib.so /usr/local/lib/php/extensions/no-debug-non-zts-20200930/

# Enable PDlib on final image
# Increse memory limits

#RUN echo "extension=pdlib.so" > /usr/local/etc/php/conf.d/pdlib.ini\
#  && echo "memory_limit=4096M" > /usr/local/etc/php/conf.d/memory-limit.ini
RUN echo "memory_limit=4096M" > /usr/local/etc/php/conf.d/memory-limit.ini




RUN mkdir /var/log/supervisord /var/run/supervisord \ 
#  && echo "*/15 * * * * su - www-data -s /bin/bash -c \"php -f /var/www/html/cron.php\""| crontab -
  && true


COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY redis.config.php /usr/src/nextcloud/config/redis.config.php

# temporary fix for https://github.com/nextcloud/server/issues/31308 (2022-06-16)
RUN apt-get update && apt-get install -y \
#  php7.4-smbclient \
  libsmbclient-dev \
  && pecl install smbclient \
  && echo "extension=smbclient.so" >> /usr/local/etc/php/conf.d/nextcloud.ini \
  && rm -rf /var/lib/apt/lists/* 


#CMD ["/usr/bin/supervisord"]
