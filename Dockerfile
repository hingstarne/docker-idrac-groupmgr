FROM jlesage/baseimage-gui:alpine-3.11

ENV APP_NAME="iDRAC" \
    IDRAC_PORT=443

COPY keycode-hack.c /keycode-hack.c

RUN apk add icedtea-web && \
    apk add curl && \
    apk add gcc && \
    apk add musl-dev && \
    apk add libx11-dev && \
    gcc -o /keycode-hack.so /keycode-hack.c -shared -s -ldl -fPIC && \
    apk del gcc && \
    apk del musl-dev && \
    apk del libx11-dev && \
    rm /keycode-hack.c

RUN mkdir /app && \
    chown ${USER_ID}:${GROUP_ID} /app

RUN mkdir /templates && \
    chown ${USER_ID}:${GROUP_ID} /templates

RUN sed -i "/jdk.tls.disabledAlgorithms/,+2 d" /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/java.security

COPY startapp.sh /startapp.sh

COPY IDRAC6.jnlp /templates/IDRAC6.jnlp
COPY IDRAC78.jnlp /templates/IDRAC78.jnlp

WORKDIR /app

ENV PATH="/usr/lib/jvm/java-1.8-openjdk/bin/:${PATH}"
