# Smallest base image
FROM alpine

LABEL maintainer="Admin <admin@liny.io>"\
    vendor="Liny"

ENV TERM=linux
RUN apk upgrade &&\
    apk add tzdata openvpn iptables supervisor dnsmasq &&\
    rm -rf /etc/openvpn

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
# EXPOSE 1194/udp
# EXPOSE 9443/tcp

ADD ./Img /

#entrypoint
CMD ["/usr/lib/liny/Entrypoint.sh"]
