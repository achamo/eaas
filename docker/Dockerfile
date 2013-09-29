FROM ubuntu:raring
MAINTAINER Arnaud Chong <shine@achamo.net>
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install eggdrop proftpd supervisor openssh-client -y
RUN ssh-keygen -t rsa -h -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t dsa -h -f /etc/ssh/ssh_host_dsa_key -N ''
RUN ssh-keygen -t ecdsa -h -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN groupadd eggdrop
RUN useradd -m -d /home/eggdrop -g eggdrop -s /bin/bash eggdrop
ADD proftpd/proftpd.conf /etc/proftpd/proftpd.conf
ADD proftpd/modules.conf /etc/proftpd/modules.conf
ADD proftpd/sftp.conf /etc/proftpd/sftp.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 22
CMD ["/usr/bin/supervisord"]
