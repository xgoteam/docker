FROM centos:7
MAINTAINER "Tom" <tom_hejiaxi@163.com>

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc; \
    sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'; \
    yum check-update; \
    yum install -y code
ENV VSCODEEXT /var/vscode-ext
ENV HOME /home/user

RUN useradd --create-home --home-dir $HOME user \
    && mkdir /work -p \
	&& chown -R user:user $HOME /work \
    && mkdir $VSCODEEXT \
    && chown -R user:user $VSCODEEXT

COPY mybin /mybin
RUN chmod +x -R /mybin
WORKDIR /work

CMD ["/mybin/start.sh"]