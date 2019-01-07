FROM solita/ubuntu-systemd:18.04

RUN apt-get update && apt-get install -y software-properties-common

#borrowed this bit from opentable/baseimage-java8
# Install Java.
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y \
  	oracle-java8-installer \
  	curl \
  	ssh \
  	sudo \
  	vim && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# **you should never do this in production**
# want sshd running for testing mendel
# set root password
RUN echo 'root:silly' | chpasswd

# make this work like it's a vagrant box
# mendel is designed to assume local deployments are vagrant deployments
RUN adduser vagrant
RUN adduser --home /srv/myservice --system --disabled-password --group myservice
RUN echo 'vagrant:vagrant' | chpasswd
RUN usermod -aG sudo vagrant

RUN adduser --home /srv/myservice-tgz --system --disabled-password --group myservice-tgz
ADD ./myservice-tgz.service /etc/systemd/system/myservice-tgz.service
RUN mkdir /srv/myservice-tgz/releases
RUN mkdir /srv/myservice-tgz/releases/init
RUN ln -sfT /srv/myservice-tgz/releases/init /srv/myservice-tgz/current
RUN chown -R myservice-tgz:myservice-tgz /srv/myservice-tgz

RUN adduser --home /srv/myservice-jar --system --disabled-password --group myservice-jar
ADD ./myservice-jar.service /etc/systemd/system/myservice-jar.service
RUN mkdir /srv/myservice-jar/releases
RUN mkdir /srv/myservice-jar/releases/init
RUN ln -sfT /srv/myservice-jar/releases/init /srv/myservice-jar/current
RUN chown -R myservice-jar:myservice-jar /srv/myservice-jar
ADD ./myservice-jar.yml /srv/myservice-jar/

RUN adduser --home /srv/myservice-remote_jar --system --disabled-password --group myservice-remote_jar
ADD ./myservice-remote_jar.service /etc/systemd/system/myservice-remote_jar.service
RUN mkdir /srv/myservice-remote_jar/releases
RUN mkdir /srv/myservice-remote_jar/releases/init
RUN ln -sfT /srv/myservice-remote_jar/releases/init /srv/myservice-remote_jar/current
RUN chown -R myservice-remote_jar:myservice-remote_jar /srv/myservice-remote_jar
ADD ./myservice-remote_jar.yml /srv/myservice-remote_jar/

# expose port for myservice
EXPOSE 8080

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1", "service sshd start"]
