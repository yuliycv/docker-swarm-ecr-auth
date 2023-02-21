FROM alpine:3.17

COPY start.sh /bin/start.sh

RUN apk add --no-cache docker aws-cli && \
    chmod +x /bin/start.sh

CMD [ "/bin/start.sh" ]
