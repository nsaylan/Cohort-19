# Hands-on Jenkins-02: Triggering Jenkins Jobs

The purpose of this hands-on training is to learn how to trigger Jenkins jobs in different ways.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Integrate your Jenkins server with GitHub

- Trigger Jenkins jobs with webhook

- Trigger Jenkins jobs with Poll SCM


## Outline

- Part 1 - Integrating Jenkins with GitHub using Webhook

- Part 2 - Integrating Jenkins Pipeline with GitHub Webhook

- Part 3 - Configuring Jenkins Pipeline with GitHub Webhook to Run the Python Code

- Part 4 - Configuring Jenkins Pipeline with GitHub Webhook to Build the Java Code

- Part 5 - Creating a Pipeline with Poll SCM

## Part 1 - Integrating Jenkins with GitHub using Webhook

- Create a public project repository `jenkins-first-webhook-project` on your GitHub account.

- Clone the `jenkins-first-webhook-project` repository on the local computer.

```bash
git clone <your-repo-url>
```
- Go to your local repository.

```bash
cd jenkins-first-webhook-project
```

- Write a simple Python code that prints `Hello World` and save it as `hello-world.py`.

```python
print('Hello World')
```

- Go back to the Jenkins dashboard and click on `New Item` to create a new job item.

- Enter `first-job-triggered` then select `free style project` and click `OK`.

```yaml
- General:
- Description: My first job triggered by GitHub

- Source Code Management:
    Git:
      Repository URL: https://github.com/<your-github-account-name>/jenkins-first-webhook-project/

    Branches to build: It must be the same branch name as your `jenkins-first-webhook-project` Github repository. If your repository's default branch name is "main", then change "master" to "main".

- Build Triggers:
    - GitHub hook trigger for GITScm polling

- Build Steps:
    Execute shell:
        python3 hello-world.py
```   

- Click `apply` and `save`.

- Go to your Github `jenkins-first-webhook-project` repository page and click on `Settings`.

- Click on the `Webhooks` on the left-hand menu, and then click on `Add webhook`.

- Copy the Jenkins URL from the AWS Management Console, paste it into the `Payload URL` field, add `/github-webhook/` at the end of the URL, and click on `Add webhook`.

```text
http://ec2-54-144-151-76.compute-1.amazonaws.com:8080/github-webhook/
```

- Commit and push the local changes to update the remote repo on GitHub.

```bash
git add .
git commit -m 'updated hello world'
git push
```

- Observe the newly built under `Build History` on the Jenkins project page.

- Explain the details of the build on the Build page.

- Go back to the project page and explain the GitHub Hook log.

## Part 2 - Integrating Jenkins Pipeline with GitHub Webhook

- Go to your Github ``jenkinsfile-pipeline-project`` repository page and click on `Settings`.

- Click on the `Webhooks` on the left hand menu, and then click on `Add webhook`.

- Copy the Jenkins URL from the AWS Management Console, paste it into the `Payload URL` field, add `/github-webhook/` at the end of URL, and click on `Add webhook`.

```text
http://ec2-54-144-151-76.compute-1.amazonaws.com:8080/github-webhook/
```

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `pipeline-with-jenkinsfile-and-webhook` then select `Pipeline` and click `OK`.

```yaml
- General:
- Description: Simple pipeline configured with Jenkinsfile and GitHub Webhook

- Build Triggers:
    - GitHub hook trigger for GITScm polling

- Pipeline:
    Definition:
        Pipeline script from SCM:
            Git:
                Repository URL:
                    - https://github.com/<your-github-account-name>/jenkinsfile-pipeline-project.git
                
                Branches to build: It must be the same branch name as your `jenkins-first-webhook-project` Github repository. If your repository's default branch name is "main", then change "master" to "main".
```

- Click `apply` and `save`. Note that the script `Jenkinsfile` should be placed under root folder of repo.

- Now, to trigger an automated build on the Jenkins Server, we need to change any file in the repo, then commit and push the change into the GitHub repository. So, update the `Jenkinsfile`on your local repository with the following pipeline script.

```groovy
pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo 'Clarusway_Way to Reinvent Yourself'
                sh 'echo Integrating Jenkins Pipeline with GitHub Webhook using Jenkinsfile'
            }
        }
    }
}
```

- Commit and push the change to the remote repo on GitHub.

```bash
git add .
git commit -m 'updated Jenkinsfile'
git push
```

- Observe the newly built triggered with `git push` command under `Build History` on the Jenkins project page.

- Explain the build results, and show the `Integrating Jenkins Pipeline with GitHub Webhook using Jenkinsfile` output from the shell.

- Explain the role of `Jenkinsfile` and GitHub Webhook in this automation.

## Part 3 - Configuring Jenkins Pipeline with GitHub Webhook to Run the Python Code

- To build the `python` code with Jenkins pipeline using the `Jenkinsfile` and `GitHub Webhook`, we will leverage the same job created in Part 2 (named as `pipeline-with-jenkinsfile-and-webhook`). 

- To accomplish this task, we need;

  - a Python code to build

  - a Python environment to run the pipeline stages on the Python code

  - A Jenkinsfile configured for an automated build on our repo

- Create a Python file on the `jenkinsfile-pipeline-project` local repository, name it as `pipeline.py`, add coding to print `My first Python job which is run within Jenkinsfile.`, and save.

```python
print('My first python job which is run within Jenkinsfile.')
```

- Update the `Jenkinsfile` with the following pipeline script, and explain the changes.

```groovy
pipeline {
    agent any
    stages {
        stage('run') {
            steps {
                echo 'Clarusway_Way to Reinvent Yourself'
                sh 'python3 --version'
                sh 'python3 pipeline.py'
            }
        }
    }
}
```

- Commit and push the changes to the remote repo on GitHub.

```bash
git add .
git commit -m 'updated jenkinsfile and added pipeline.py'
git push
```

- Observe the newly built trigger with the `git push` command on the Jenkins project page.

## Part 4 - Configuring Jenkins Pipeline with GitHub Webhook to Build the Java Code

- To build the `Java` code with Jenkins pipeline using the `Jenkinsfile` and `GitHub Webhook`, we need;

  - a Java code to build

  - a Java environment to run the build stages on the Java code

  - a Jenkinsfile configured for an automated build on our repo

- Create a Java file on the `jenkins-pipeline-project` local repository, name it as `Hello.java`, add coding to print `Hello from Java` and save.

```java
public class Hello {

    public static void main(String[] args) {
        System.out.println("Hello from Java");
    }
}
```

- Since the Jenkins Server is running on the Java platform, we can leverage from the already available Java environment.

- Update the `Jenkinsfile` with the following pipeline script, and explain the changes.


```groovy
pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo 'Compiling the Java source code'
                sh 'javac Hello.java'
            }
        }
        stage('run') {
            steps {
                echo 'Running the compiled Java code.'
                sh 'java Hello'
            }
        }
    }
}
```

- Commit and push the changes to the remote repo on GitHub.

```bash
git add .
git commit -m 'updated Jenkinsfile and added Hello.java'
git push
```

- Observe the newly built triggered with the `git push` command on the Jenkins project page.

- Explain the role of the Java environment, `Jenkinsfile`, and GitHub Webhook in this automation.


## Part 5 - Creating a Pipeline with Poll SCM

- Go to the Jenkins dashboard and click on `New Item` to create a pipeline.

- Enter `jenkinsfile-pipeline-pollSCM` then select `Pipeline` and click `OK`.

```yaml
- General:
- Description: This is a pipeline project with pollSCM

- Build Triggers:
    - Poll SCM: * * * * *

- Pipeline:
    Definition:
        `Pipeline script from SCM:
            Git:
                Repository URL:
                    - https://github.com/<your-github-account-name>/jenkinsfile-pipeline-project.git
                
                Branches to build: It must be the same branch name as your `jenkins-first-webhook-project` Github repository. If your repository's default branch name is "main", then change "master" to "main".
```

- `Save` the configuration.

- Go to the GitHub repo and modify some part in the `Jenkinsfile` and commit.

- Observe the auto build action at the Jenkins job.
