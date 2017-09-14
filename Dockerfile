FROM busybox:latest

# -- expose the volume to jenkins-master
VOLUME /usr/share/jenkins/sidekick

# -- copy the init script that will be the new entrypoint for jenkins-master
COPY jenkins-init.sh /usr/share/jenkins/sidekick/jenkins-init.sh

# -- later add other seutp scripts to config/init.groovy.d
#COPY config/init.groovy.d /usr/share/jenkins/sidekick/init.groovy.d
