FROM debian:testing

ADD NPB3.4.tar.gz /
COPY make.def /NPB3.4/NPB3.4-MPI/config/
COPY suite.def /NPB3.4/NPB3.4-MPI/config/
ADD deb /rdma-core-deb
RUN apt-get update && dpkg -i /rdma-core-deb/* ; apt --fix-broken install -y && \
  apt-get install -f -y build-essential cmake gcc libudev-dev libnl-3-dev \
  libnl-route-3-dev ninja-build pkg-config valgrind python3-dev cython3 \
  autoconf libtool-bin git pandoc python-docutils \
  gdb libopenmpi3 libopenmpi-dev tini openssh-server && \
  useradd -m user && \
  git clone --depth 1 https://github.com/linux-rdma/perftest.git && \
  cd NPB3.4/NPB3.4-MPI && make suite && cp bin/* /usr/bin/ && \
  cd /perftest && ./autogen.sh && ./configure && make && make install && \ 
  apt purge -y autoconf libtool-bin git pandoc python-docutils \
  cmake gcc ninja-build valgrind pkg-config && \
  apt autoremove -y && \
  rm -rf /rdma-core-deb /perftest /NPB3.4

USER user

ENTRYPOINT ["tini", "--"]
