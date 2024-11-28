FROM google/cloud-sdk:alpine

RUN apk add --update --no-cache bash ca-certificates curl git jq openssh && \
    gcloud components install kubectl gke-gcloud-auth-plugin --quiet

# Required for GKE authentication in 1.25+ clusters
ENV USE_GKE_GCLOUD_AUTH_PLUGIN=True

RUN mkdir -p /src

COPY src /src/

ENTRYPOINT ["/src/main.sh"]
