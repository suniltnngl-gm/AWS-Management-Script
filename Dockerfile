FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    jq \
    unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && apt-get clean
RUN useradd -m -s /bin/bash vscode
WORKDIR /app
COPY . .
RUN chmod +x *.sh bin/*.sh tools/*.sh
USER vscode
ENTRYPOINT ["./aws-cli.sh"]
