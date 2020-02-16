FROM debian:testing

RUN apt-get update && \
  apt-get install -y build-essential cmake gcc libudev-dev libnl-3-dev \
  libnl-route-3-dev ninja-build pkg-config valgrind python3-dev cython3 \
  autoconf libtool-bin git pandoc python-docutils && \
  git clone --depth 1 https://github.com/linux-rdma/rdma-core.git && \
  git clone  --depth 1 https://github.com/linux-rdma/perftest.git && \
  cd /rdma-core && mkdir build && cd build && cmake .. && make && make install && \
  cd /perftest && ./autogen.sh && ./configure && make && make install && \
  apt purge -y autoconf libtool-bin git pandoc python-docutils \
  cmake gcc ninja-build valgrind pkg-config && \
  apt autoremove -y && \
  rm -rf /rdma-core /perftest

RUN useradd -m user && apt install -y tini

RUN apt install -y gdb
USER user

ENTRYPOINT ["tini", "--"]
