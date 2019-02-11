FROM alpine:latest
LABEL author="Ivan Shcherbak <alotofall@gmail.com>"
LABEL "com.github.actions.name"="Create PR"
LABEL "com.github.actions.description"="Create PR based on condition"
LABEL "com.github.actions.icon"="send"
LABEL "com.github.actions.color"="blue"
RUN	apk add bash ca-certificates curl jq
COPY create-pr.sh /usr/bin/create-pr
ENTRYPOINT ["create-pr"]
