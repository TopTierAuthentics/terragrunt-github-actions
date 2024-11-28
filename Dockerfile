FROM google/cloud-sdk:alpine

RUN apk add --update --no-cache bash ca-certificates curl git jq openssh && \
    gcloud components install gke-gcloud-auth-plugin

RUN mkdir -p /src

COPY src /src/

ENTRYPOINT ["/src/main.sh"]
