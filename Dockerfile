FROM docker.io/centos:latest
RUN \
    yum -y update && \
    yum -y install bash libaio* curl unzip openssl git vim gcc make && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    mkdir -p /opt/oracle/network/admin && touch /opt/oracle/network/admin/tnsnames.ora && mkdir -p /opt/oracle/pkg-config && \
    mkdir -p ~/code/golang/{3rd,my}/src

ADD  ["go1.9.3.linux-amd64.tar.gz","/opt/"]
COPY ["instantclient-basiclite-linux.x64-12.2.0.1.0.zip","instantclient-sdk-linux.x64-12.2.0.1.0.zip","instantclient-sqlplus-linux.x64-12.2.0.1.0.zip","/opt/oracle/"]
COPY ["oci8.pc","/opt/oracle/pkg-config/"]

RUN \
    cd /opt/oracle && \
    ls *.zip | xargs -I {} unzip {} && \
    rm -rf *.zip /opt/go.tar.gz && cd /opt/oracle/instantclient_12_2 && \
    ln -s libclntsh.so.12.1 libclntsh.so && ln -s libocci.so.12.1 libocci.so && \
    sh -c "echo /opt/oracle/instantclient_12_2 > /etc/ld.so.conf.d/oracle-instantclient.conf" && ldconfig

ENV ORCL_INSTC /opt/oracle/instantclient_12_2
ENV PKG_CONFIG_PATH /opt/oracle/pkg-config
ENV TNS_ADMIN /opt/oracle/network/admin
ENV LD_LIBRARY_PATH $ORCL_INSTC:$LD_LIBRARY_PATH
ENV GOROOT /opt/go
ENV GOPATH /root/code/golang/3rd:/root/code/golang/my
ENV PATH $ORCL_INSTC:$GOROOT/bin:$PKG_CONFIG_PATH:$PATH

EXPOSE 80 443
CMD ["/bin/bash"]
