FROM jlesage/baseimage-gui:ubuntu-16.04

ENV APP_NAME="iDRAC" \
    IDRAC_PORT=443

COPY keycode-hack.c /keycode-hack.c

RUN apt-get update && \
    apt-get install -y curl software-properties-common && \
    add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk gcc icedtea-netx && \
    gcc -o /keycode-hack.so /keycode-hack.c -shared -s -ldl -fPIC && \
    apt-get remove -y gcc software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm /keycode-hack.c

RUN mkdir /app && \
    chown ${USER_ID}:${GROUP_ID} /app

RUN mkdir /templates && \
    chown ${USER_ID}:${GROUP_ID} /templates

RUN sed -i "/jdk.tls.disabledAlgorithms/,+2 d" /etc/java-8-openjdk/security/java.security

COPY startapp.sh /startapp.sh

COPY IDRAC6.jnlp /templates/IDRAC6.jnlp
COPY IDRAC78.jnlp /templates/IDRAC78.jnlp

WORKDIR /app
