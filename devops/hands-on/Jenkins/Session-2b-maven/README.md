# Hands-on Jenkins-03: Java and Maven Jobs in Jenkins

The purpose of this hands-on training is to learn how to install Java and Maven on the Jenkins Server and configure Maven/Java Jobs.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- install and configure Maven,

- create Java and Maven jobs

## Outline

- Part 1 - Maven Settings

- Part 2 - Creating Package Application - Free Style Maven Job

- Part 3 - Configuring Jenkins Pipeline with GitHub Webhook to Build a Java Maven Project

## Part 1 - Maven Settings

- Set a specific Maven Release in Jenkins for usage
- Go to `Manage Jenkins` page
- Select `Tools`
- To the bottom, `Maven` section
  - Give a name such as `maven-3.9.9`
  - Select `install automatically`
  - `Install from Apache` version `3.9.9`
- Save

## Part 2 - Creating Package Application - Free Style Maven Job

- Select `New Item`

- Enter name as `package-application`

- Select `Free Style Project`

```yaml
- General:
- Description: This Job packages the Java-Tomcat-Sample Project and creates a war file.

- Discard old builds: 
   Strategy:
     Log Rotation:
       Days to keep builds: 5 
       Max#of builds to keep: 3

- Source Code Management:
    Git:
      Repository URL: https://github.com/clarusway-aws-devops/java-tomcat-sample-main.git

    Branches to build: Go to the web browser and check the branch name of the git project `https://github.com/clarusway-aws-devops/java-tomcat-sample-main.git`.

- It is a public repo, no need for `Credentials`.

- Build Environments: 
   - Delete the workspace before the build starts
   - Add timestamps to the Console Output

- Build Steps:
    Invoke top-level Maven targets:
      - Maven Version: maven-3.9.9
      - Goals: clean package
  - POM: pom.xml

- Post-build Actions:
    Archive the artifacts:
      Files to archive: **/*.war 
```

- Finally, `Save` the job.

- Select `package-application`

- Click the `Build Now` option.

- Observe the Console Output


## Part 3 - Configuring Jenkins Pipeline with GitHub Webhook to Build a Java Maven Project

- In this part, we're going to use a Maven installation available on the built-in node.

- Install Maven
  
```bash
sudo su
cd /opt
rm -rf maven
wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
tar -zxvf $(ls | grep apache-maven-*-bin.tar.gz)
rm -rf $(ls | grep apache-maven-*-bin.tar.gz)
mv apache-maven-3.9.9 maven
echo 'export M2_HOME=/opt/maven' > /etc/profile.d/maven.sh
echo 'export PATH=${M2_HOME}/bin:${PATH}' >> /etc/profile.d/maven.sh
exit
source /etc/profile.d/maven.sh
```

- Open Jenkins GUI on a web browser

- Setting System Maven Path for default usage
  
- Go to `Manage Jenkins`
  - Select `System`
  - Find the `Environment variables` section,
  - Click `Add`
    - for `Name`, enter `PATH+EXTRA` 
    - for `Value`, enter `/opt/maven/bin`
- Save

- To build the `Java Maven project` with Jenkins pipeline using the `Jenkinsfile` and `GitHub Webhook`. To accomplish this task, we need;

  - a Java code to build

  - a Java environment to run the build stages on the Java code

  - a maven environment to run the build stages on the Java code

  - a Jenkinsfile configured for an automated build on our repo

- Create a public project repository `jenkins-maven-project` on your GitHub account.

- Clone the `jenkins-maven-project` repository on the local computer.

- Copy the files given within the hands-on folder [hello-app](./hello-app)  and paste under the `jenkins-maven-project` GitHub repo folder.

- Go to your Github `jenkins-maven-project` repository page and click on `Settings`.

- Click on the `Webhooks` on the left-hand menu, and then click on `Add webhook`.

- Copy the Jenkins URL from the AWS Management Console, paste it into the `Payload URL` field, add `/github-webhook/` at the end of URL, and click on `Add webhook`.

```text
http://ec2-54-144-151-76.compute-1.amazonaws.com:8080/github-webhook/
```

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `pipeline-with-jenkinsfile-and-webhook-for-maven-project` then select `Pipeline` and click `OK`.

```yaml
- General:
- Description: Simple pipeline configured with Jenkinsfile and GitHub Webhook for Ma aven project

- Build Triggers:
    - GitHub hook trigger for GITScm polling

- Pipeline:
    Definition:
        Pipeline script from SCM:
            Git:
                Repository URL:
                    - https://github.com/<your_github_account_name>/jenkins-maven-project/
                
                Branches to build: It must be the same branch name as your `jenkins-first-webhook-project` Github repository. If your repository's default branch name is "main", then change "master" to "main".
```

- Click `apply` and `save`. Note that the script `Jenkinsfile` should be placed under root folder of repo.

- Create a `Jenkinsfile` with the following pipeline script, and explain the script.

- For a native structured Jenkins Server

```groovy
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'mvn -f hello-app/pom.xml test'
            }
            post {
                always {
                    junit 'hello-app/target/surefire-reports/*.xml'
                }
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -f hello-app/pom.xml -B -DskipTests clean package'
            }
            post {
                success {
                    echo "Now Archiving the Artifacts....."
                    archiveArtifacts artifacts: '**/*.jar'
                }
            }
        }
    }
}
```

- Commit and push the changes to the remote repo on GitHub.

```bash
git add .
git commit -m 'added Jenkinsfile and Maven project'
git push
```

- Observe the newly built triggered with the `git push` command on the Jenkins project page.
