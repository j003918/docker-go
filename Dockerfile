FROM docker.io/centos:latest
RUN \
    yum -y update && \
    yum -y install bash libaio* curl unzip openssl openssh-server gcc make && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key     -N '' && \
    ssh-keygen -t ecdsa       -f /etc/ssh/ssh_host_ecdsa_key   -N '' && \
    ssh-keygen -t ed25519     -f /etc/ssh/ssh_host_ed25519_key -N '' && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    mkdir -p /opt/oracle/network/admin

ADD  ["go1.9.3.linux-amd64.tar.gz","/opt/"]
COPY ["instantclient-basic-linux.x64-12.2.0.1.0.zip","/opt/oracle/"]
COPY ["instantclient-sqlplus-linux.x64-12.2.0.1.0.zip","/opt/oracle/"]

RUN \
    cd /opt/oracle && \
    unzip instantclient-basic-linux.x64-12.2.0.1.0.zip && \
    unzip instantclient-sqlplus-linux.x64-12.2.0.1.0.zip && \
    rm -rf *.zip /opt/go.tar.gz && cd /opt/oracle/instantclient_12_2 && \
    ln -s libclntsh.so.12.1 libclntsh.so && ln -s libocci.so.12.1 libocci.so && \
    sh -c "echo /opt/oracle/instantclient_12_2 > /etc/ld.so.conf.d/oracle-instantclient.conf" && ldconfig

ENV ORCL_INSTC /opt/oracle/instantclient_12_2
ENV LD_LIBRARY_PATH $ORCL_INSTC:$LD_LIBRARY_PATH
ENV GOROOT /opt/go
ENV PATH $ORCL_INSTC:$GOROOT/bin:$PATH

EXPOSE 22 80 443 8080
#CMD ["/usr/sbin/sshd", "-D"]
CMD ["/bin/bash"]
