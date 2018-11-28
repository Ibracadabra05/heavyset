FROM ubuntu:18.04

RUN apt-get update && apt-get install -y software-properties-common

#borrowed this bit from opentable/baseimage-java8
# Install Java.
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y \
  	oracle-java8-installer \
  	curl \
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

# replicate sprout_java LWRP for tgz
RUN adduser --home /srv/myservice-tgz --system --disabled-password --group myservice-tgz
ADD ./myservice-tgz.service /etc/systemd/system/myservice-tgz.service
RUN mkdir /srv/myservice-tgz/releases
RUN mkdir /srv/myservice-tgz/releases/init
RUN ln -sfT /srv/myservice-tgz/releases/init /srv/myservice-tgz/current
RUN chown -R myservice-tgz:myservice-tgz /srv/myservice-tgz


# expose port for myservice
EXPOSE 8080

CMD ["/sbin/init"]