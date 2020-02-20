FROM debian:testing

ADD NPB3.4.tar.gz /
COPY make.def /NPB3.4/NPB3.4-MPI/config/
COPY suite.def /NPB3.4/NPB3.4-MPI/config/
ADD ./openmpi-4.0.2.tar.gz /

RUN apt-get update && \
  apt-get install -f -y build-essential cmake gcc libudev-dev libnl-3-dev \
  libnl-route-3-dev ninja-build pkg-config valgrind python3-dev cython3 \
  autoconf libtool-bin git pandoc python-docutils gfortran libgfortran5 \
  gdb tini openssh-server libnuma1 libnuma-dev && \
  useradd -m user && \
  cd / && git clone --single-branch --branch mplaneta/rxe-workaround https://github.com/planetA/rdma-core.git && \
    cd rdma-core && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. && make -j $(nproc) && make install && \
  cd / && git clone --branch v1.6.1 --depth 1 https://github.com/openucx/ucx.git && cd ucx && ./autogen.sh && ./configure --with-rc && make -j $(nproc) && make install && \
  cd /openmpi-4.0.2 && \
  ./configure --with-ucx --prefix=/usr --without-verbs --enable-mca-no-build=btl-uct \
    --disable-openib-rdmacm --disable-openib-udcm --enable-mpi-fortran && \
  make -j $(nproc) && make install && \
  cd /NPB3.4/NPB3.4-MPI && make suite && cp bin/* /usr/bin/ && \
  cd / &&  git clone --depth 1 https://github.com/linux-rdma/perftest.git && \
  cd /perftest && ./autogen.sh && ./configure && make && make install && \ 
  apt purge -y autoconf libtool-bin git pandoc python-docutils \
  cmake gcc ninja-build valgrind pkg-config && \
  apt autoremove -y && apt-get clean -y && apt-get autoclean -y && \
  rm -rf /ucx /perftest /NPB3.4 /openmpi-4.0.2 && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
  sed -i -e 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
  echo 'user:user' | chpasswd

ADD hosts /etc/hosts

USER user

RUN ssh-keygen -f /home/user/.ssh/id_rsa -N "" -q && \
  cp /home/user/.ssh/id_rsa.pub /home/user/.ssh/authorized_keys

ENTRYPOINT ["tini", "--"]
