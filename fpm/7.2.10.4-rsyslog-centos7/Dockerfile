FROM xgoteam/fpm:7.2.10.3-rsyslog-centos7

#Install luasocket
RUN (git clone https://github.com/diegonehab/luasocket.git && cd luasocket && \
     make clean && make all && make install && cd ..)
#Install lua-cjson
RUN (git clone https://github.com/mpx/lua-cjson.git && cd lua-cjson && \
    make --file=/lua-cjson/Makefile && make install && \
    cp cjson.so /usr/local/lib/lua/5.1/ && cd ..)
#Install  lua-cmsgpack
RUN (git clone https://github.com/antirez/lua-cmsgpack.git && \
    cd lua-cmsgpack && rm -rf CMakeCache.txt && cmake . && make clean && \
    make --file=/lua-cmsgpack/Makefile && make install && cd ..)
#Install msgpack-c
RUN (git clone https://github.com/msgpack/msgpack-c.git && \
     cd  msgpack-c && rm -rf CMakeCache.txt && cmake . && make clean && \
     make --file=/msgpack-c/Makefile && make install && cd ..)

RUN yum install -y lua-devel cmake gcc-c++.x86_64
RUN  (wget http://luajit.org/download/LuaJIT-2.0.5.tar.gz && \
        tar -zxf LuaJIT-2.0.5.tar.gz && \
        cd LuaJIT-2.0.5 && \
        make --file=/LuaJIT-2.0.5/Makefile && make install && \
        cd ..)
        
#Install  luajit
COPY lua /lua
RUN chmod -R 755 /lua
#复制kg_hook扩展
COPY ext/kg_hook.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20170718/kg_hook.so
COPY libc.conf  /etc/ld.so.conf.d/libc.conf
RUN ldconfig

COPY etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf
COPY etc/php.ini /usr/local/php/lib/php.ini
COPY etc/rsyslog.conf /etc/rsyslog.conf
COPY etc/rsyslog.d /etc/rsyslog.d
COPY start.sh /start.sh
COPY entrypoint.sh /entrypoint.sh
RUN  chmod +x /start.sh; \
     chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]
