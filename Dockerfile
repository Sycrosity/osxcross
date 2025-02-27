FROM ubuntu:latest

RUN /bin/bash -c "yes | unminimize"

RUN /bin/bash -c "apt update -y -qq && \
    apt install -y -qq curl sudo openssh-server && \
    apt install -y -qq clang llvm-dev libxml2-dev uuid-dev libssl-dev bash patch make \
    cmake tar xz-utils bzip2 gzip sed cpio libbz2-dev zlib1g-dev && \
    apt install -y -qq clang pkg-config libx11-dev libasound2-dev libudev-dev && \
    apt install -y -qq lld libssl-dev lzma-dev libxml2-dev && \
    apt install -y -qq git && \
    apt install rsync gpg -y -qq"

RUN /bin/bash -c "cd / && \
    git clone https://github.com/Sycrosity/osxcross && \
    cd /osxcross && \
    UNATTENDED=yes OSX_VERSION_MIN=10.7 ./build.sh"

RUN /bin/bash -c "echo 'PATH="/vscode/bin:/osxcross/target/bin:$PATH"' >> '$HOME/.bashrc' && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    source '$HOME/.cargo/env' && \
    echo -e '[target.x86_64-apple-darwin]\n\
linker = \"x86_64-apple-darwin22.2-clang\"\n\
ar = \"x86_64-apple-darwin22.2-ar\"\n\
[env]\n\
CC_x86_64-apple-darwin=\"o64-clang\"\n\
[install]\n\
root = \"/vscode/\"' > '$HOME/.cargo/config.toml' && \
    rustup target add x86_64-apple-darwin"


    #useradd -rm -d /home/vscode -s /bin/bash -g root -G sudo -u 1000 vscode && \
RUN /bin/bash -c "service ssh start && \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin without-password' >> /etc/ssh/sshd_config && \
    mkdir -p '$HOME/.ssh/'"

ENTRYPOINT [ "/usr/sbin/sshd", "-D" ]
# CMD [ "/usr/sbin/sshd", "-D" ]
