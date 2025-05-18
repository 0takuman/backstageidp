FROM node:20-bookworm-slim

# Set Python interpreter for `node-gyp` to use
ENV PYTHON=/usr/bin/python3
ENV DEBIAN_FRONTEND=noninteractive
ENV HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
ENV PATH="${HOMEBREW_PREFIX}/bin:${HOMEBREW_PREFIX}/sbin:${PATH}"

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev build-essential \
        curl \
        file \
        git \
        python3 \
        sudo \
        procps \
        ruby \
        && \
        rm -rf /var/lib/apt/lists/*

# Install Homebrew
RUN git clone https://github.com/Homebrew/brew ${HOMEBREW_PREFIX}/Homebrew \
    && mkdir -p ${HOMEBREW_PREFIX}/bin \
    && ln -s ${HOMEBREW_PREFIX}/Homebrew/bin/brew ${HOMEBREW_PREFIX}/bin/brew \
    && brew update --force

# Run brew doctor to confirm install
RUN brew doctor || true

# Install Homebrew packages
RUN brew install fish tmux eza

# Create non-root user
RUN if getent passwd $DockerUID > /dev/null; then userdel -r $(getent passwd $DockerUID | cut -d ':' -f 1); fi \
    && groupadd --force --gid $DockerGID $DockerUSER \
    && useradd --no-log-init --uid $DockerUID --gid $DockerGID -m $DockerUSER \
    && mkdir -p /etc/sudoers.d/ \
    && echo $DockerUSER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$DockerUSER \
    && chmod 0440 /etc/sudoers.d/$DockerUSER

# From here on we use the least-privileged `node` user to run the backend.
USER ${DockerUSER}
WORKDIR /home/${DockerUSER}

# Copy files needed by Yarn
COPY --chown=${DockerUID}:${DockerGID} .yarn ./.yarn
COPY --chown=${DockerUID}:${DockerGID} .yarnrc.yml ./
COPY --chown=${DockerUID}:${DockerGID} backstage.json ./

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV=production

# This disables node snapshot for Node 20 to work with the Scaffolder
ENV NODE_OPTIONS="--no-node-snapshot"

# Copy repo skeleton first, to avoid unnecessary docker cache invalidation.
# The skeleton contains the package.json of each package in the monorepo,
# and along with yarn.lock and the root package.json, that's enough to run yarn install.
COPY --chown=${DockerUID}:${DockerGID} yarn.lock package.json packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# This will include the examples, if you don't need these simply remove this line
COPY --chown=${DockerUID}:${DockerGID} examples ./examples

# Then copy the rest of the backend bundle, along with any other files we might want.
COPY --chown=${DockerUID}:${DockerGID} packages/backend/dist/bundle.tar.gz app-config*.yaml ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]