#!/bin/bash

# -- tell Jenkins start up code that this instance is already configured
echo "$JENKINS_VERSION" > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
echo "$JENKINS_VERSION" > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

# -- copy other init.groovy.d scripts
cp /usr/share/jenkins/sidekick/init.groovy.d/*.groovy /usr/share/jenkins/ref/init.groovy.d/

# -- copy initial config.xml file
cp /usr/share/jenkins/sidekick/config/* /usr/share/jenkins/ref/

# -- check and wait if plugins.txt does not exist
while [ ! -f /usr/share/jenkins/sidekick/plugins.txt ]; do
    sleep 1
done

# -- install all required plugins
/usr/local/bin/install-plugins.sh < /usr/share/jenkins/sidekick/plugins.txt

# -- execute the jenkins.sh script from parent image
exec /bin/tini -- /usr/local/bin/jenkins.sh
