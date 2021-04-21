FROM python:3

RUN mkdir /playinfra
WORKDIR /playinfra

COPY requirements.txt .
COPY localfacts.yml .

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

RUN set -x \
    && addgroup --system --gid 102 nginx \
    && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx \
    && apt update && apt-get install -y git nginx vim \
    && ansible-galaxy collection install netapp.ontap \
    && ansible-galaxy collection install netapp.elementsw \
    && ansible-galaxy collection install netapp.um_info \ 
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj '/C=US/ST="New York"/L="New York"/O="Scandanavian Ventures, Inc."/CN=ansibleservice.com/emailAddress=gustav@foobar.com/OU=NetApp' \
    && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx-plus.list \
    && rm -rf /etc/apt/apt.conf.d/90nginx /etc/ssl/nginx \
    && git clone https://github.com/ScryptBrewer/AIQ_Workload_classification.git \
    && git clone https://github.com/NetApp/Ansible-with-Active-IQ-Unified-Manager.git \
    && git clone https://github.com/ScryptBrewer/netapp_ansible_collections_templates.git \
    && git clone https://github.com/NetApp/ansible.git \
    && mkdir -p ~/.ansible/plugins/modules \
    && cp Ansible-with-Active-IQ-Unified-Manager/aiqum_modules/* ~/.ansible/plugins/modules/ \
    && rm -fr Ansible-with-Active-IQ-Unified-Manager

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ENTRYPOINT ["nginx", "-g", "daemon off;"]
