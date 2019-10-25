# blr-beach-devops-task
As a DevOps practitioner we were supposed to create the infra followed by the CI/CD pipeline till the dev environment for the open source project(petclinic) available at : https://github.com/spring-projects/spring-petclinic

## Getting started
In order to get the project, pease fork it and clone it, in order to build it, please run the "terraform init" followed by "terraform plan" and "terraform apply" commands.

### Prerequisites
In order to build and run the project we need the following:
- Azure Account
- Terraform

### Installing
In order to run the project, please follow the steps mentioned below:
- Clone the project
- Run "az login" to login to your azure account
- Run the commands: "terraform init" followed by "terraform plan" and "terraform apply"

When we run the above commands what happens is as follows:
- Firstly we have created a docker image for custom installation of jenkins, with the properties suitable to our requirements and push it docker hub.
- A resource group gets create first followed by a VNet.
- Then two subnets get created, at this stage both the subnets will be private, as per the task we are supposed to make one of the subnets public in order to access from the outside the network, hence we attach a "public Ip" to it.
- Then we create a "VM" inside the public subnet, then we install our required resources in it, like docker and jenkins (installed from the image pushed to docker hub in first step)
- Now, using the public ip available on public vm we login to jenkins and run the seed job which was part of the jenkins image available in docker hub. This job creates a pipeline job in jenkins which we run to build our project from "https://github.com/spring-projects/spring-petclinic", after the project is built we create a docker image as part of the build pipeline and push it to docker hub.
- Now, in the private subnet we create a "VM" where we pull and run the docker image generated in the previous step.
- In order to access the project deployed in the private VM, we have created a load balancer which is associated with a public ip through which we can access the project from outisde the network. This load balancer is internally mapped to the private VM for it to route traffic coming in at a particular port(8080).

After this our project is ready to be accessed at the url: http://<ip>:8080.
  
### Note
- Update github url in config.xml ,docker username in docker-init.sh ,spring-petclinic-init.sh , Jenkinsfile.
- Also Commit Jenkinsfile and Dockerfile to your forked repo (in my case it’s https://github.com/SalmanHauq/spring-petclinic).
