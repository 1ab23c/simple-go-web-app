FROM ubuntu:18.04

ARG go_binary
# download golang and add to the path:
ADD ${go_binary} /usr/local/
ENV PATH ${PATH}:/usr/local/go/bin/

EXPOSE 8080

COPY main /
ENTRYPOINT /main
