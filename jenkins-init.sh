#!/bin/bash

# -- install OS level packages required by build tools
mkdir $JENKINS_HOME/.local
dpkg-deb -x /usr/share/jenkins/sidekick/packages/groff-base_1.22.3-9_amd64.deb $JENKINS_HOME/.local
dpkg-deb -x /usr/share/jenkins/sidekick/packages/less_481-2.1_amd64.deb $JENKINS_HOME/.local

# -- update PATH for user installed packages
export PATH=$JENKINS_HOME/.local/bin:$JENKINS_HOME/.local/usr/bin:$PATH

# -- add chefdk path if installed
if [[ -d /opt/chefdk ]]; then
  export PATH=/opt/chefdk/bin:$PATH
fi

# -- tell Jenkins start up code that this instance is already configured
echo -n "$JENKINS_VERSION" > $JENKINS_HOME/jenkins.install.UpgradeWizard.state
echo -n "$JENKINS_VERSION" > $JENKINS_HOME/jenkins.install.InstallUtil.lastExecVersion

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
cat /dev/zero | ssh-keygen -q -N "" 
if [[ -f /run/secrets/GIT_SSH_KEY ]]; then
  cat /run/secrets/GIT_SSH_KEY > $JENKINS_HOME/.ssh/git_id_rsa
  chmod 600 $JENKINS_HOME/.ssh/git_id_rsa
  cat << EOF > ~/.ssh/config
Host ${GIT_HOSTNAME:-"*"}
  StrictHostKeyChecking no
  IdentityFile ~/.ssh/git_id_rsa
EOF
else
  cat << EOF > ~/.ssh/config
Host ${GIT_HOSTNAME:-"*"}
  StrictHostKeyChecking no
  IdentityFile ~/.ssh/id_rsa
EOF
fi
if [[ -z $GIT_HOSTNAME ]]; then
    ssh-keyscan $GIT_HOSTNAME >> ~/.ssh/known_hosts
fi

# -- install all required plugins
/usr/local/bin/install-plugins.sh < /usr/share/jenkins/sidekick/plugins.txt

# -- add .local tool installations to the path
export PATH=$JENKINS_HOME/.local/bin:$PATH

# -- execute the jenkins.sh script from parent image
exec /bin/tini -- /usr/local/bin/jenkins.sh
