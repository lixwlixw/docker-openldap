#
# VERSION               0.0.3

# it is based on https://github.com/rackerlabs/dockerstack/blob/master/keystone/openldap/Dockerfile 
# also the files/more.ldif from http://www.zytrax.com/books/ldap/ch14/#ldapsearch

FROM  index.alauda.cn/library/ubuntu:trusty

MAINTAINER Larry Cai "larry.caiyu@gmail.com"

# install slapd in noninteractive mode
RUN apt-get update && \
	echo 'slapd/root_password password password' | debconf-set-selections &&\
    echo 'slapd/root_password_again password password' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils &&\
	rm -rf /var/lib/apt/lists/*

ADD files /ldap



EXPOSE 389

CMD ["/ldap/run-openldap.sh"]
