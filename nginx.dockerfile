FROM node:16.20 as intermediate

COPY ./ ./
RUN files/prebuild/write-version.sh
RUN files/prebuild/build-frontend.sh

# when upgrading, look for upstream changes to redirector.conf
# also, confirm setup-odk.sh strips out HTTP-01 ACME challenge location
FROM jonasal/nginx-certbot:4.2.0

EXPOSE 80
EXPOSE 443

VOLUME [ "/etc/dh", "/etc/selfsign", "/etc/nginx/conf.d" ]
ENTRYPOINT [ "/bin/bash", "/scripts/setup-odk.sh" ]

RUN apt-get update && apt-get install -y netcat-openbsd

RUN mkdir -p /usr/share/odk/nginx/

COPY files/nginx/setup-odk.sh /scripts/
COPY files/local/customssl/*.pem /etc/customssl/live/local/
COPY files/nginx/*.conf* /usr/share/odk/nginx/

COPY --from=intermediate client/dist/ /usr/share/nginx/html
COPY --from=intermediate /tmp/version.txt /usr/share/nginx/html
