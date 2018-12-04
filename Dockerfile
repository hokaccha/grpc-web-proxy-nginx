FROM ubuntu:18.04

ARG GRPC_DIR=/grpc-web/third_party/grpc
ARG GRPC_LIB=$GRPC_DIR/libs/opt
ARG PROTO_DIR=$GRPC_DIR/third_party/protobuf
ARG PROTO_LIB=$PROTO_DIR/src/.libs

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    ca-certificates \
    g++ \
    gcc \
    git \
    libpcre3-dev \
    libssl-dev \
    libtool \
    make \
    zlib1g-dev

RUN groupadd -r nginx && useradd -r -d /var/cache/nginx -s /sbin/nologin -g nginx nginx
RUN git clone --branch 1.0.3 https://github.com/grpc/grpc-web /grpc-web \
    && cd /grpc-web \
    && git submodule update --init --recursive -- third_party/grpc \
    && git submodule update --init -- third_party/nginx/src

RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN cd $GRPC_DIR && make install
RUN cd $PROTO_DIR && make install

RUN cd /grpc-web && make protos
RUN cd /grpc-web/third_party/nginx/src \
    && LD_LIBRARY_PATH="-L$PROTO_LIB:$GRPC_LIB" \
    auto/configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --user=nginx \
    --group=nginx \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-debug \
    --with-cc-opt="-I /usr/local/include -I /grpc-web -I $GRPC_DIR -I $GRPC_DIR/include -I $PROTO_DIR/src -I $PROTO_DIR/include -Wno-error" \
    --with-ld-opt="-L$PROTO_LIB -L$GRPC_LIB -l:libgrpc++.a -l:libgrpc.a -l:libprotobuf.a -lpthread -ldl -lrt -lstdc++ -lm" \
    --add-module="/grpc-web/net/grpc/gateway/nginx" \
    && make \
    && make install
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/conf.d/grpc_proxy.conf /etc/nginx/conf.d/grpc_proxy.conf

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
