FROM ubuntu:24.04

ARG USERNAME=hluser
ARG USER_UID=10000
ARG USER_GID=$USER_UID

# Define URLs as environment variables
ARG PUB_KEY_URL=https://raw.githubusercontent.com/hyperliquid-dex/node/refs/heads/main/pub_key.asc
ARG HL_VISOR_URL=https://binaries.hyperliquid.xyz/Mainnet/hl-visor
ARG HL_VISOR_ASC_URL=https://binaries.hyperliquid.xyz/Mainnet/hl-visor.asc

# Create user and install dependencies
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update -y && apt-get install -y curl gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/$USERNAME/hl/data && chown -R $USERNAME:$USERNAME /home/$USERNAME/hl

USER $USERNAME
WORKDIR /home/$USERNAME

# Configure chain to testnet
RUN echo '{"chain": "Mainnet"}' > /home/$USERNAME/visor.json
RUN echo '{ "root_node_ips": [{"Ip": "20.188.6.225"},{"Ip": "74.226.182.22"},{"Ip": "57.182.103.24"},{"Ip": "3.115.170.40"},{"Ip": "46.105.222.166"},{"Ip": "91.134.41.52"},{"Ip": "57.180.50.253"},{"Ip": "54.248.41.39"},{"Ip": "52.68.71.160"},{"Ip": "199.254.199.247"},{"Ip": "13.114.116.44"},{"Ip": "199.254.199.190"},{"Ip": "72.46.87.191"},{"Ip": "45.32.32.21"},{"Ip": "157.90.207.92"},{"Ip": "57.129.140.247"},{"Ip": "91.134.71.237"},{"Ip": "148.251.76.7"},{"Ip": "45.63.123.73"},{"Ip": "31.223.196.172"},{"Ip": "31.223.196.238"},{"Ip": "160.202.131.51"},{"Ip": "72.46.87.141"},{"Ip": "148.251.76.7"},{"Ip": "45.63.123.73"},{"Ip": "31.223.196.172"},{"Ip": "31.223.196.238"}], "try_new_peers": true, "chain": "Mainnet" }' > /home/$USERNAME/override_gossip_config.json

# Import GPG public key
RUN curl -o /home/$USERNAME/pub_key.asc $PUB_KEY_URL \
    && gpg --import /home/$USERNAME/pub_key.asc

# Download and verify hl-visor binary
RUN curl -o /home/$USERNAME/hl-visor $HL_VISOR_URL \
    && curl -o /home/$USERNAME/hl-visor.asc $HL_VISOR_ASC_URL \
    && gpg --verify /home/$USERNAME/hl-visor.asc /home/$USERNAME/hl-visor \
    && chmod +x /home/$USERNAME/hl-visor

RUN sysctl -w net.ipv4.tcp_rmem="4096 87380 8388608"
RUN sysctl -w net.ipv4.tcp_wmem="4096 16384 8388608"

# Expose gossip ports
EXPOSE 4000
EXPOSE 4001
EXPOSE 4002
EXPOSE 4003
EXPOSE 4004
EXPOSE 4005
EXPOSE 4006
EXPOSE 4007
EXPOSE 4008
EXPOSE 4009
EXPOSE 4010
EXPOSE 3001

# Run a non-validating node
ENTRYPOINT ["/home/hluser/hl-visor", "run-non-validator", "--serve-eth-rpc", "--write-trades", "--write-order-statuses"]