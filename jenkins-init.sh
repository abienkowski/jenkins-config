#!/bin/bash

# -- tell Jenkins start up code that this instance is already configured
echo "2.0" > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

# -- TODO: copy other init.groovy.d scripts
# cp /usr/share/jenkins/sidekick/some-groovy-script.groovy /usr/share/jenkins/ref/init.groovy.d/

# -- copy initial config.xml file
cp /config.xml /usr/share/jenkins/ref/config.xml

# -- check and wait if plugins.txt does not exist
while [ ! -f /usr/share/jenkins/sidekick/plugins.txt ]; do
    sleep 1
done

# -- install all required plugins
/usr/local/bin/install-plugins.sh < /usr/share/jenkins/sidekick/plugins.txt

# -- execute the jenkins.sh script from parent image
exec /bin/tini -- /usr/local/bin/jenkins.sh
