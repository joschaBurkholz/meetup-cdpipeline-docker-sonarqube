#
# Creates a docker container with SonarQube, incl. several plugins
# Since the original Dockerfile does not support plugins, I
# had to extend the Dockerfile
#
# Original: https://hub.docker.com/_/sonarqube/
#

FROM jre

MAINTAINER Joscha Burkholz <joscha.burkholz@mgx.de>

ENV SONAR_VERSION 6.2
ENV SONARQUBE_HOME /opt/sonarqube

# Plugin Versions
ENV SONAR_JAVA_PLUGIN 4.3.0.7717
ENV SONAR_WEB_PLUGIN 2.4
ENV SONAR_LDAP_PLUGIN 2.1.0.507
ENV SONAR_SCM_GIT_PLUGIN 1.0
ENV SONAR_CLOVER_PLUGIN 3.1

RUN groupadd -r sonarqube -g 3002 && \
    useradd -u 3002 -r -g sonarqube -m -d /opt/sonarqube -s /bin/bash -c "Sonarqube Run User" sonarqube

# Http port
EXPOSE 9000

# H2 Database port
EXPOSE 9092

# Install packages necessary
RUN yum -y install unzip && yum clean all

# Add SonarQube binaries from Nexus Repository
ADD https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip $SONARQUBE_HOME/sonarqube-${SONAR_VERSION}.zip

# Unpack SonarQube Zip
RUN set -x \
	&& unzip $SONARQUBE_HOME/sonarqube-${SONAR_VERSION}.zip \
	&& mv sonarqube-${SONAR_VERSION}/* $SONARQUBE_HOME \
	&& rm $SONARQUBE_HOME/sonarqube-${SONAR_VERSION}.zip

# Add plugins
RUN mkdir -p $SONARQUBE_HOME/extensions/plugins/
ADD http://central.maven.org/maven2/org/sonarsource/java/sonar-java-plugin/${SONAR_JAVA_PLUGIN}/sonar-java-plugin-${SONAR_JAVA_PLUGIN}.jar $SONARQUBE_HOME/extensions/plugins/sonar-java-plugin-${SONAR_JAVA_PLUGIN}.jar
ADD http://central.maven.org/maven2/org/sonarsource/sonar-web-plugin/sonar-web-plugin/${SONAR_WEB_PLUGIN}/sonar-web-plugin-${SONAR_WEB_PLUGIN}.jar $SONARQUBE_HOME/extensions/plugins/sonar-web-plugin-${SONAR_WEB_PLUGIN}.jar
ADD http://central.maven.org/maven2/org/sonarsource/ldap/sonar-ldap-plugin/${SONAR_LDAP_PLUGIN}/sonar-ldap-plugin-${SONAR_LDAP_PLUGIN}.jar $SONARQUBE_HOME/extensions/plugins/sonar-ldap-plugin-${SONAR_LDAP_PLUGIN}.jar
ADD http://central.maven.org/maven2/org/codehaus/sonar-plugins/sonar-scm-git-plugin/${SONAR_SCM_GIT_PLUGIN}/sonar-scm-git-plugin-${SONAR_SCM_GIT_PLUGIN}.jar $SONARQUBE_HOME/extensions/plugins/sonar-scm-git-plugin-${SONAR_SCM_GIT_PLUGIN}.jar
ADD http://central.maven.org/maven2/org/sonarsource/clover/sonar-clover-plugin/${SONAR_CLOVER_PLUGIN}/sonar-clover-plugin-${SONAR_CLOVER_PLUGIN}.jar $SONARQUBE_HOME/extensions/plugins/sonar-clover-plugin-${SONAR_CLOVER_PLUGIN}.jar

COPY run.sh $SONARQUBE_HOME

RUN chown -R sonarqube:sonarqube $SONARQUBE_HOME && \
    chmod -R 777 $SONARQUBE_HOME

WORKDIR $SONARQUBE_HOME
USER sonarqube

VOLUME ["$SONARQUBE_HOME/data","$SONARQUBE_HOME/conf","$SONARQUBE_HOME/logs"]

CMD ["/opt/sonarqube/run.sh"]
