#!/bin/bash

# -- tell Jenkins start up code that this instance is already configured
echo "$JENKINS_VERSION" > $JENKINS_HOME/jenkins.install.UpgradeWizard.state

# -- copy other init.groovy.d scripts
cp -u /usr/share/jenkins/sidekick/init.groovy.d/*.groovy /usr/share/jenkins/ref/init.groovy.d/

# -- copy initial config.xml file
cp -u /usr/share/jenkins/sidekick/config/* /usr/share/jenkins/ref/

# -- check and wait if plugins.txt does not exist
while [ ! -f /usr/share/jenkins/sidekick/plugins.txt ]; do
    sleep 1
done

# -- inject LDAP secrets into environment
export LDAP_MANAGER_DN="$(cat /run/secrets/LDAP_MANAGER_DN)"
export LDAP_MANAGER_KEY="$(cat /run/secrets/LDAP_MANAGER_KEY)"

# -- create private ssh key from secrets and create known_hosts file
mkdir -p $JENKINS_HOME/.ssh
cat /run/secrets/GIT_SSH_KEY > $JENKINS_HOME/.ssh/id_rsa
chmod 600 $JENKINS_HOME/.ssh/id_rsa
if [[ -z $GIT_HOSTNAME ]]; then
    ssh-keyscan $GIT_HOSTNAME >> ~/.ssh/known_hosts
fi

# -- install all required plugins
/usr/local/bin/install-plugins.sh < /usr/share/jenkins/sidekick/plugins.txt

# -- execute the jenkins.sh script from parent image
exec /bin/tini -- /usr/local/bin/jenkins.sh
