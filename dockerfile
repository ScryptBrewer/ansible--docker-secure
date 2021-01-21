FROM python:3

WORKDIR /

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

RUN set -x \
    && addgroup --system --gid 102 nginx \
    && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx \
    && apt update && apt-get install -y git nginx \
    && ansible-galaxy collection install netapp.ontap \
    && ansible-galaxy collection install netapp.elementsw \
    && ansible-galaxy collection install netapp.um_info \ 
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj '/C=US/ST="New York"/L="New York"/O="Scandanavian Ventures, Inc."/CN=ansibleservice.com/emailAddress=gustav@foobar.com/OU=NetApp' \
    && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx-plus.list \
    && rm -rf /etc/apt/apt.conf.d/90nginx /etc/ssl/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY localfacts.yml /

EXPOSE 80

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ENTRYPOINT ["nginx", "-g", "daemon off;"]