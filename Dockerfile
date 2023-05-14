FROM ubuntu:22.04

RUN apt-get -y update --fix-missing
RUN apt-get -y --fix-missing --allow-downgrades install curl wget gcc build-essential lld m4 libgmp3-dev libmpfr-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup.sh
RUN chmod +x ./rustup.sh
RUN ./rustup.sh --default-toolchain nightly-x86_64-unknown-linux-gnu --target x86_64-unknown-linux-gnu -y
ENV PATH=/root/.cargo/bin:$PATH
RUN rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu

WORKDIR /root
RUN wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-12.1.0/gcc-12.1.0.tar.gz 
RUN tar zxvf ./gcc-12.1.0.tar.gz
WORKDIR /root/gcc-12.1.0
RUN ./contrib/download_prerequisites
RUN mkdir build
WORKDIR /root/gcc-12.1.0/build
RUN ../configure --enable-languages=c,c++  --disable-bootstrap --disable-multilib
RUN make -j $(nproc)
RUN make install -j $(nproc)

ENV PATH=/usr/local/bin:$PATH

RUN gcc --version
RUN ln -sf /usr/local/bin/gcc /usr/bin/gcc

WORKDIR /root
RUN rm /root/gcc-12.1.0 -rf

WORKDIR /root
RUN wget https://github.com/rui314/mold/releases/download/v1.3.1/mold-1.3.1-x86_64-linux.tar.gz
RUN tar zxvf mold-1.3.1-x86_64-linux.tar.gz

ENV PATH=/root/mold-1.3.1-x86_64-linux/bin:$PATH

RUN echo $PATH
RUN chmod +x /lib/x86_64-linux-gnu/libc.so.6
RUN /lib/x86_64-linux-gnu/libc.so.6
RUN cargo --version
RUN ld.lld --version
RUN mold --version


