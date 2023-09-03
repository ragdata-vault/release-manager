FROM alpine:3.18

COPY ./src/bin			/usr/bin/
COPY ./entrypoint.sh	/usr/bin

RUN apk add --no-cache bash git curl jq

ENTRYPOINT ["/bin/bash","/usr/bin/entrypoint.sh"]
