# s2i-spring-boot-tomcat-build
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
# LABEL maintainer="Your Name <your@email.com>"

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building s2i-spring-boot-tomcat-build image" \
      io.k8s.display-name="builder x.y.z" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,x.y.z,etc." \
      io.openshift.s2i.destination="/opt/s2i/destination" \
      # this label tells s2i where to find its mandatory scripts
      # (run, assemble, save-artifacts)
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

ARG OPENJDK_VERSION=1.8.0
ARG MAVEN_VERSION=3.3.9

ENV MAVEN_VERSION=${MAVEN_VERSION}

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN INSTALL_PKGS="tar unzip bc which lsof java-${OPENJDK_VERSION}-openjdk java-${OPENJDK_VERSION}-openjdk-devel" && \
    yum install -y --enablerepo=centosplus ${INSTALL_PKGS} && \
    rpm -V ${INSTALL_PKGS} && \
    yum clean all -y && \
    (curl -v https://www.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    ln -sf /usr/local/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2

	
COPY ./maven/settings.xml $HOME/.m2/

# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y
#RUN yum install -y rubygems && yum clean all -y
#RUN gem install asdf

# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
# RUN chown -R 1001:1001 /opt/app-root

RUN chown -R 1001:0 $HOME

RUN chmod +x /usr/libexec/s2i/assemble && \
	chmod +x /usr/libexec/s2i/run && \
	mkdir -p /opt/s2i/destination && \
	chmod -R g+rw /opt/s2i/destination && \
	mkdir -p /opt/java && \
	chmod -R g+rw /opt/java

WORKDIR /opt/s2i/destination

# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
