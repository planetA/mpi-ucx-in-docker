FROM debian:testing

ADD ../NPB3.4.tar.gz /
COPY ../make.def /NPB3.4/NPB3.4-MPI/config/
COPY ../suite.def /NPB3.4/NPB3.4-MPI/config/

RUN apt-get update && \
  apt-get install -f -y build-essential cmake gcc libudev-dev libnl-3-dev \
  libnl-route-3-dev ninja-build pkg-config valgrind python3-dev cython3 \
  autoconf libtool-bin git pandoc python-docutils gfortran libgfortran5 \
  gdb tini openssh-server libnuma1 libnuma-dev wget && \
  useradd -m user && \
  cd / && git clone --single-branch --branch mplaneta/rxe-workaround https://github.com/planetA/rdma-core.git && \
    cd rdma-core && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. && make -j $(nproc) && make install && \
  cd / && wget http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-2.3.3.tar.gz && tar xf mvapich2-2.3.3.tar.gz && cd mvapich2-2.3.3 && \
    ./configure --disable-mcast --disable-xrc --disable-rdma-cm --without-hwloc --prefix=/usr && \
    make -j $(nproc) && make install && \
  cd /NPB3.4/NPB3.4-MPI && make suite && cp bin/* /usr/bin/ && \
  cd / &&  git clone --depth 1 https://github.com/linux-rdma/perftest.git && \
  cd /perftest && ./autogen.sh && ./configure && make && make install && \ 
  apt purge -y autoconf libtool-bin git pandoc python-docutils wget \
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
