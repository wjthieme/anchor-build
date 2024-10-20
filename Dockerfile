FROM debian:bullseye-slim

ARG RUSTC_VERSION="v1.78.0"
ARG NODE_VERSION="v22.8.0"
ARG SOLANA_VERSION="v1.17.25"
ARG ANCHOR_VERSION="v0.29.0"

# Install base utilities.
RUN apt-get update -qq && apt-get upgrade -qq && apt-get install -qq \
    build-essential pkg-config libudev-dev curl

# Install rust.
ENV PATH="/.cargo/bin:${PATH}"
RUN curl -O "https://static.rust-lang.org/dist/rust-${RUSTC_VERSION#v}-x86_64-unknown-linux-gnu.tar.xz" && \
    tar -xvf rust-${RUSTC_VERSION#v}-x86_64-unknown-linux-gnu.tar.xz && \
    sh ./rust-${RUSTC_VERSION#v}-x86_64-unknown-linux-gnu/install.sh && \
    rm rust-${RUSTC_VERSION#v}-x86_64-unknown-linux-gnu.tar.xz && \
    rm -r rust-${RUSTC_VERSION#v}-x86_64-unknown-linux-gnu

# Install node.
ENV PATH="/node-${NODE_VERSION}-linux-x64/bin:${PATH}"
RUN curl -O "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz" && \
    tar -xvf node-${NODE_VERSION}-linux-x64.tar.xz && \
    rm node-${NODE_VERSION}-linux-x64.tar.xz

# Install Solana.
ENV PATH="/solana-release/bin:${PATH}"
RUN curl -O "https://release.anza.xyz/${SOLANA_VERSION}/solana-release-x86_64-unknown-linux-gnu.tar.bz2" && \
    tar -xvf solana-release-x86_64-unknown-linux-gnu.tar.bz2 && \
    rm solana-release-x86_64-unknown-linux-gnu.tar.bz2

# Install Anchor.
RUN npm install -g @coral-xyz/anchor-cli@${ANCHOR_VERSION#v}

# Install yarn.
RUN npm install -g yarn

# Build a dummy program to bootstrap the BPF SDK (doing this speeds up builds).
RUN anchor init dummy && cd dummy && (anchor build || true) && cd .. && rm -r dummy

# Set up the working directory
RUN mkdir /workdir
WORKDIR /workdir

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
