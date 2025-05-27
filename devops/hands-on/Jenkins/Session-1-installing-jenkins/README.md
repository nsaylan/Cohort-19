# Hands-on Jenkins-01: Installing Jenkins on Amazon Linux 2023 EC2 Instance

Purpose of this hands-on training is to learn how to install Jenkins Server on an Amazon Linux 2023 EC2 instance and build simple jobs.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Install and configure Jenkins Server on Amazon Linux 2023 EC2 instance using `dnf` repo.

- Install plugins

- Create a view

- Create simple Free Style jobs

- Create simple Pipeline jobs

- Create a simple Pipeline with Jenkinsfile


## Outline

- Part 1 - Installing Jenkins Server on Amazon Linux 2023 with `dnf` Repo

- Part 2 - Getting familiar with Jenkins Dashboard

- Part 3 - Installing Plugins

- Part 4 - Creating a view

- Part 5 - Creating First Jenkins Job

- Part 6 - Creating a Simple Pipeline with Jenkins

- Part 7 - Creating a Jenkins Pipeline with Jenkinsfile

## Part 1 - Installing Jenkins Server on Amazon Linux 2023 with `dnf` Repo

- Launch an AWS EC2 instance of Amazon Linux 2023 AMI with security group allowing SSH and TCP 8080 ports.

- Connect to the instance with SSH.

```bash
ssh -i .ssh/call-training.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

- Download the Jenkins repository configuration file and save it as /etc/yum.repos.d/jenkins.repo. The package manager uses this file to know where to find Jenkins packages.

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
```

- Imports the GPG key required to verify Jenkins packages. It ensures that the packages are from a trusted source.

```bash
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
```

- Upgrade all the installed packages on your system to their latest versions.

```bash
sudo dnf upgrade
```

- Install two dependencies needed for Jenkins to run properly:

> fontconfig: This is a library used to configure and customize font rendering.

> java-17-amazon-corretto: This installs the Java 17-amazon-corretto, the Java runtime environment required by Jenkins.

```bash
sudo dnf install fontconfig java-21-amazon-corretto-devel -y
```

- Check the Java version.

```bash
java -version
```

- Install Jenkins.

```bash
sudo dnf install jenkins -y
```

- Tell systemd (the system and service manager for Linux) to reload its configuration files. This is necessary after installing a new service like Jenkins.

```bash
sudo systemctl daemon-reload
```

- Enable the Jenkins service so that Jenkins can restart automatically after reboots.

```bash
sudo systemctl enable jenkins
```

- Start the Jenkins service.

```bash
sudo systemctl start jenkins
```

- Check if the Jenkins service is up and running.

```bash
sudo systemctl status jenkins
```

- Get the initial administrative password.

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
- Open your browser, get your EC2 instance's Public IPv4 DNS and paste it in the address bar with 8080. 
"http://[ec2-public-dns-name]:8080"

- Enter the temporary password to unlock Jenkins.

- Install suggested plugins.

- Create the first admin user.

- Check the URL, then save and finish the installation.

- Install Git

```bash
sudo dnf install git -y
```

## Part 2 - Getting familiar with Jenkins Dashboard

- Explain `Jenkins` dashboard.

- Explain `Items` options.

- Explain `Manage Jenkins` dashboard.

- Explain other Jenkins terminology.

## Part 3 - Installing Plugins

- Follow `Manage Jenkins` -> `Manage Plugins` path and install the plugins (install without restart):

  -  `AnsiColor`
    
  -  `Copy Artifact`

  -  `Deploy to container`

## Part 4 - Creating First Jenkins Job

- We will create a job in Jenkins that picks up a simple "Hello World" bash script and runs it. The freestyle build job is a highly flexible and easy-to-use option. To create a Jenkins freestyle job;

  - Open your Jenkins dashboard and click on `New Item` to create a new job item.

  - Enter `my-first-job` then select `free style project` and click `OK`.

  - Enter `My first jenkins job` in the description field.

  - Explain `Source Code Management`, `Build Triggers`,  `Build Environment`, `Build`, `Post-build Actions` tabs.

    ```text
    1. Source Code Management Tab: optional SCM, such as CVS or Subversion, where your source code resides.
    2. Build Triggers: Optional triggers to control when Jenkins will perform builds.
    3. Build Environment: Some sort of build script that performs the build 
    (ant, maven, shell script, batch file, etc.) where the real work happens
    4. Build: Optional steps to collect information from the build, 
    such as archiving the artifacts and/or recording Javadoc and test results.
    5. Post-build Actions: Optional steps to notify other people/systems 
    with the build result, such as sending e-mails, IMs, updating the issue tracker, etc.
    ```

  - Go to `Build` section and choose "Execute Shell Command" step from the `Add build step` dropdown menu.

  - Write down just `echo "Hello World, This is my first job"` to execute a shell command, in the text area shown.

  - Click `apply` and `save`  buttons.

- On the Project job page, click `Build now`.

- Show and explain the result of this build action under the `Build History`

  - Click on the build number to reach the build page.

  - Show the console results from `Console Output`.

## Part 5 - Creating a view

- Click `+` on the right of `All` tab.

- Give a name like `my view` on the `New View` page.

- Select `List View` option

- Click the `Create` button, select `my first job` from the `Jobs` list, and click `save`.

## Part 6 - Creating a Simple Pipeline with Jenkins

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `simple-pipeline` then select `Pipeline` and click `OK`.

- Enter `My first simple pipeline` in the description field.

- Go to the `Pipeline` section, enter the following script, then click `apply` and `save`.

```text
pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo "Clarusway_Way to Reinvent Yourself"
                sh 'echo second step'
                sh 'echo another step'                
                sh '''
                echo 'Multiline'
                echo 'Example'
                '''
                echo 'not using shell'
            }
        }
    }
}
```

- Go to the project page and click `Build Now`.

- Explain the results.

- Explain the pipeline script.

## Part 7 - Creating a Jenkins Pipeline with Jenkinsfile

- Create a public project repository `jenkinsfile-pipeline-project` on your GitHub account.

- Clone the `jenkinsfile-pipeline-project` repository on the local computer.

```bash
git clone <your-repo-url>
```
- Create a `Jenkinsfile` within your local `jenkinsfile-pipeline-project` repo and save the following pipeline script. Consider that the filename 'Jenkinsfile' is case sensitive.

```groovy
pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo "Clarusway_Way to Reinvent Yourself"
                sh 'echo using shell within Jenkinsfile'
                echo 'not using shell in the Jenkinsfile'
            }
        }
    }
}
```

- Commit and push the local changes to update the remote repo on GitHub.

```bash
git add .
git commit -m 'added Jenkinsfile'
git push
```

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `pipeline-from-jenkinsfile`, then select `Pipeline` and click `OK`.

- Enter `Simple pipeline configured with Jenkinsfile` in the description field.

- Go to the `Pipeline` section, and select `Pipeline script from SCM` in the `Definition` field.

- Select `Git` in the `SCM` field.

- Enter the URL of the project repository, and let others be the default.

```text
https://github.com/<your_github_account_name>/jenkinsfile-pipeline-project/
```

- Click `apply` and `save`. Note that the script `Jenkinsfile` should be placed under root folder of repo.

- Go to the Jenkins project page and click `Build Now`.

- Explain the role of `Jenkinsfile` and the built results.
