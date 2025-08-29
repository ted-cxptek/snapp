# Multi-stage build to get the e2ee-chat-server binary
FROM tedcxptek/e2ee-chat-server:latest AS server

# Main stage with Ubuntu for Lokinet (better package support)
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary tools for Lokinet and database operations
RUN apt update && apt install -y curl lsb-release resolvconf dnsutils sqlite3 make

# Add Oxen repository and install Lokinet
RUN curl -so /etc/apt/trusted.gpg.d/oxen.gpg https://deb.oxen.io/pub.gpg
RUN echo "deb https://deb.oxen.io `lsb_release -sc` main" > /etc/apt/sources.list.d/oxen.list
RUN apt update && apt install -y lokinet

# Setup Lokinet
RUN chown _lokinet:_loki /var/lib/lokinet -R
RUN /usr/bin/lokinet -g
RUN lokinet-bootstrap
RUN chown _lokinet:_loki /var/lib/lokinet -R

# Configure DNS resolution for .loki domains
RUN mkdir -p /etc/resolvconf/resolv.conf.d
RUN echo "nameserver 127.3.2.1" > /etc/resolvconf/resolv.conf.d/head
RUN echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head

# Create script to get loki address
RUN echo "#!/bin/bash" > /get_loki_address.sh
RUN echo "host -t cname localhost.loki 127.3.2.1" >> /get_loki_address.sh
RUN chmod +x /get_loki_address.sh

# Copy Lokinet config
RUN cp /var/lib/lokinet/lokinet.ini /

# Copy the e2ee-chat-server binary and related files from the server stage
COPY --from=server /server /server
COPY --from=server /conf.json /conf.json
COPY --from=server /migrations /migrations
COPY --from=server /Makefile /Makefile

# Create data directory for the e2ee-chat-server database
RUN mkdir -p /data && chmod 755 /data

# Create startup script
RUN echo "#!/bin/bash" > /start.sh
RUN echo "cp -n /lokinet.ini /var/lib/lokinet/" >> /start.sh
RUN echo "/usr/bin/lokinet -g" >> /start.sh
RUN echo "sed -ie 's|#keyfile=|keyfile=/var/lib/lokinet/snappkey.private|g' /var/lib/lokinet/lokinet.ini" >> /start.sh
RUN echo "sed -ie 's|#ifaddr=|ifaddr=10.67.0.1/16|g' /var/lib/lokinet/lokinet.ini" >> /start.sh
RUN echo "rm -rf /var/lib/lokinet/nodedb/" >> /start.sh
RUN echo "rm -rf /var/lib/lokinet/profiles.dat" >> /start.sh
RUN echo "echo 'Starting Lokinet daemon...'" >> /start.sh
RUN echo "/usr/bin/lokinet &" >> /start.sh
RUN echo "echo 'Waiting for Lokinet to be ready...'" >> /start.sh
RUN echo "sleep 15" >> /start.sh
RUN echo "echo 'Updating DNS configuration...'" >> /start.sh
RUN echo "resolvconf -u" >> /start.sh
RUN echo "echo 'DNS configured for .loki domains.'" >> /start.sh
RUN echo "echo 'Initializing database using Makefile...'" >> /start.sh
RUN echo "cd /" >> /start.sh
RUN echo "make migrate_db_sqlite" >> /start.sh
RUN echo "echo 'Database initialization completed.'" >> /start.sh
RUN echo "echo 'Starting e2ee-chat-server...'" >> /start.sh
RUN echo "exec /server" >> /start.sh
RUN chmod +x /start.sh

EXPOSE 3000 8002

ENTRYPOINT ["/start.sh"]
