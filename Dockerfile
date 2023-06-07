FROM ubuntu:latest

RUN /bin/bash -c "apt update -y -qq && \
    apt install -y -qq curl sudo openssh-server && \
    apt install -y clang llvm-dev libxml2-dev uuid-dev libssl-dev bash patch make \
    cmake tar xz-utils bzip2 gzip sed cpio libbz2-dev zlib1g-dev && \
    apt install -y clang pkg-config libx11-dev libasound2-dev libudev-dev && \
    apt install -y lld libssl-dev lzma-dev libxml2-dev && \
    apt install -y git"

RUN /bin/bash -c " mkdir -p /usr/local/opt/llvm/bin/ && \
    ln -s /usr/bin/lld /usr/local/opt/llvm/bin/ld64.lld && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    source '$HOME/.cargo/env' && \
    rustup target add x86_64-apple-darwin"

RUN /bin/bash -c "cd /tmp && \
    git clone https://github.com/Sycrosity/osxcross && \
    cd osxcross && \
    UNATTENDED=yes OSX_VERSION_MIN=10.7 ./build.sh"

RUN /bin/bash -c "useradd -rm -d /home/vscode -s /bin/bash -g root -G sudo -u 1000 vscode && \
    echo 'PasswordAuthentication no' /etc/ssh/sshd_config && \
    service ssh start && \
    mkdir -p '$HOME/.ssh/'"

CMD [ "/usr/sbin/sshd", "-D" ]
