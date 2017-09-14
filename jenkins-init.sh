#!/bin/bash

# -- tell Jenkins start up code that this instance is already configured
echo $JENKINS_VERSION > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

# -- TODO: copy other init.groovy.d scripts
# cp /usr/share/jenkins/sidekick/some-groovy-script.groovy /usr/share/jenkins/ref/init.groovy.d/

# -- copy initial config.xml file
# cp /usr/share/jenkins/sidekick/config.xml /usr/share/jenkins/ref/config.xml

while [ ! -f /usr/share/jenkins/sidekick/plugins.txt ]; do
    sleep 1
done

# -- install all required plugins
/usr/local/bin/install-plugins.sh < /usr/share/jenkins/sidekick/plugins.txt

exec /bin/tini -- /usr/local/bin/jenkins.sh
