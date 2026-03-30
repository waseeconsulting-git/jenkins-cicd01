#!/bin/bash
dnf update -y
dnf install -y dnf-plugins-core fontconfig java-21-amazon-corretto-devel

dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
dnf install -y terraform

wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf install -y jenkins

# 1. EBS TEMP DIRECTORY
mkdir -p /var/lib/jenkins/tmp
chown jenkins:jenkins /var/lib/jenkins/tmp
chmod 700 /var/lib/jenkins/tmp

mkdir -p /etc/systemd/system/jenkins.service.d
cat <<EOF > /etc/systemd/system/jenkins.service.d/override.conf[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.io.tmpdir=/var/lib/jenkins/tmp"
Environment="JENKINS_JAVA_CMD=/usr/bin/java"
EOF
systemctl daemon-reload

# 2. IDENTITY MANAGEMENT
RANDOM_PWD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24)
echo "----------------------------------------------------------------" | tee -a /var/log/cloud-init-output.log
echo "JENKINS INITIAL ADMIN PASSWORD: $RANDOM_PWD" | tee -a /var/log/cloud-init-output.log
echo "----------------------------------------------------------------" | tee -a /var/log/cloud-init-output.log

# 3. BOOTSTRAP
mkdir -p /var/lib/jenkins/init.groovy.d/
echo "2.462" > /var/lib/jenkins/jenkins.install.UpgradeWizard.state
echo "2.462" > /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion

cat <<EOF > /var/lib/jenkins/init.groovy.d/basic-security.groovy
#!groovy
import jenkins.model.*
import hudson.security.*
def instance = Jenkins.get()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin', '$RANDOM_PWD')
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF
chown -R jenkins:jenkins /var/lib/jenkins

# 4. RESILIENT PLUGIN INSTALLS
curl -fLs -o /tmp/jenkins-plugin-manager.jar \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.14.0/jenkins-plugin-manager-2.14.0.jar

PLUGINS="git workflow-aggregator aws-credentials pipeline-aws ec2 terraform github github-oauth pipeline-github"

for p in $PLUGINS; do
  sudo -u jenkins java -jar /tmp/jenkins-plugin-manager.jar \
    --war /usr/share/java/jenkins.war \
    --plugin-download-directory /var/lib/jenkins/plugins \
    --plugins "$p" || echo "Failed to install $p, moving on..."
done


systemctl enable --now jenkins