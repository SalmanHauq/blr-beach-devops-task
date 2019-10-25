
#this is the base image we use to create our image from

FROM jenkins/jenkins:2.201-slim
 
USER root
RUN apt-get update -qq \
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common 
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
RUN apt-get update  -qq \
    && apt-get install docker-ce=17.12.1~ce-0~debian -y
RUN usermod -aG docker jenkins
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
COPY plugin.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY jobs/1-github-seed-job.xml /usr/share/jenkins/ref/jobs/1-github-seed-job/config.xml