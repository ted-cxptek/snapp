FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt upgrade -y
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
RUN apt install curl lsb-release resolvconf dnsutils --yes
RUN curl -so /etc/apt/trusted.gpg.d/oxen.gpg https://deb.oxen.io/pub.gpg
RUN echo "deb https://deb.oxen.io `lsb_release -sc` main" > /etc/apt/sources.list.d/oxen.list
RUN apt update
RUN apt install lokinet --yes
RUN apt install nginx --yes
RUN chown _lokinet:_loki /var/lib/lokinet -R
RUN /usr/bin/lokinet -g
RUN lokinet-bootstrap
RUN chown _lokinet:_loki /var/lib/lokinet -R
RUN echo "#!/bin/bash" > /get_loki_address.sh
RUN echo "host -t cname localhost.loki 127.3.2.1" >> /get_loki_address.sh
RUN chmod +x /get_loki_address.sh
RUN cp /var/lib/lokinet/lokinet.ini /
RUN echo "#!/bin/bash" > /start.sh
RUN echo "cp -n /lokinet.ini /var/lib/lokinet/" >> /start.sh
RUN echo "/usr/bin/lokinet -g" >> /start.sh
RUN echo "sed -ie 's|#keyfile=|keyfile=/var/lib/lokinet/snappkey.private|g' /var/lib/lokinet/lokinet.ini" >> /start.sh
RUN echo "sed -ie 's|#ifaddr=|ifaddr=10.67.0.1/16|g' /var/lib/lokinet/lokinet.ini" >> /start.sh
RUN echo "rm -rf /var/lib/lokinet/nodedb/" >> /start.sh
RUN echo "rm -rf /var/lib/lokinet/profiles.dat" >> /start.sh
RUN echo "service nginx start" >> /start.sh
RUN echo "/usr/bin/lokinet" >> /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
