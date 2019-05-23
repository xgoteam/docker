FROM xgoteam/python36:latest

# supervisor installation
RUN pip3.6 install supervisor

RUN mkdir -p /etc/supervisord.d/
ADD etc/supervisord.conf /etc/supervisord.conf

COPY start.sh /work/start.sh
CMD /work/start.sh