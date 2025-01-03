FROM golang:1.23 AS builder

WORKDIR /build

RUN git clone https://github.com/Zxilly/GARD

WORKDIR /build/GARD

RUN go build -ldflags "-s -w" -o gard

FROM runner:ubuntu

COPY --from=builder /build/GARD/gard /usr/local/bin/gard

ENV RUNNER_LOCATION=/opt/runner

USER root

RUN apt-get install --no-install-recommends -y -qq bzip2 \
    sudo swig telnet time zip libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python3-tk \
    libharfbuzz-dev libfribidi-dev libxcb1-dev curl g++ gcc make jq tar unzip wget \
    autoconf automake dbus dnsutils dpkg dpkg-dev fakeroot fonts-noto-color-emoji \
    gnupg2 iproute2 iputils-ping libyaml-dev libtool libssl-dev locales mercurial \
    openssh-client p7zip-rar pkg-config python-is-python3 rpm texinfo tk tree tzdata \
    xvfb xz-utils zsync acl aria2 binutils bison brotli coreutils file findutils flex \
    ftp haveged lz4 m4 mediainfo net-tools p7zip-full parallel patchelf \
    pigz pollinate rsync shellcheck sqlite3 ssh sshpass

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        python3 python3-dev python3-pip python3-venv

RUN echo "[global]\nbreak-system-packages = true" > /etc/pip.conf

RUN python3 -m pip install pipx && \
    python3 -m pipx ensurepath

RUN curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n -o ~/n && \
    bash ~/n lts && \
    chmod -R 777 /usr/local/lib/node_modules /usr/local/bin && \
    rm -rf ~/n

USER ubuntu

ENV PATH="/home/ubuntu/.local/bin:$PATH"

RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain=stable --profile=minimal
ENV PATH="$PATH:/home/ubuntu/.cargo/bin"

RUN pipx install poetry

ENTRYPOINT ["/usr/local/bin/gard"]