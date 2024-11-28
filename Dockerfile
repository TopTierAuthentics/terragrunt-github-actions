FROM google/cloud-sdk:alpine

RUN apk add --update --no-cache bash ca-certificates curl git jq openssh

RUN mkdir -p /src

COPY src /src/

ENTRYPOINT ["/src/main.sh"]
