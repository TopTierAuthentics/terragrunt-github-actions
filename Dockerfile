FROM alpine:3 

RUN yum install unzip git jq openssh -y

RUN mkdir -p /src

COPY src /src/

ENTRYPOINT ["/src/main.sh"]
