FROM alpine:latest
RUN apk add --no-cache bash curl jq aws-cli
WORKDIR /app
COPY build/aws-management-scripts-2.0.0/ .
RUN chmod +x *.sh
ENTRYPOINT ["./aws-cli.sh"]
