FROM ubuntu:bionic

RUN apt update && apt upgrade -y

RUN apt install -y simplestreams ubuntu-cloudimage-keyring ca-certificates

CMD ["/bin/bash", "/entrypoint.sh"]
