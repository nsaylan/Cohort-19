# Hands-on ECS-02 : FRONTEND AND BACKEND CONNECTION IN AWS ECS

Purpose of the this hands-on training is to give basic understanding of frontend and backend connection in AWS ECS.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- prepare a Docker Machine with terraform.

- Deploy application to AWS ECS using aws management console.

- Use AWS Cloud Map service.

## Outline

- Part 1 - Launching a Docker Machine Instance Configured for ECR Management

- Part 2 - Containerize the Application and Push Image to ECR

- Part 3 - Deploy the Application

- Part 4 - Creating a cluster with a Fargate Linux task using the AWS CLI

- Part 5 - Amazon ECS using AWS Copilot

## Part 1 - Launching a Docker Machine Instance Configured for ECR Management

- Launch a Compose enabled Docker machine on Amazon Linux 2023 AMI with security group allowing HTTP and SSH connections using the cloudformation.

## Part 3 - Deploy the Application

### Create an Amazon ECS cluster

- Navigate to the [Amazon ECS console](https://console.aws.amazon.com/ecs/home?).

- From the Amazon ECS left navigation menu, select `Clusters`.

- Select Create `cluster`.

- For the Cluster name, enter `phonebook-cluster`.

- Keep the other parameters as default.

- Click create.

### Write a Task Definition for database

- Task definitions specify how Amazon ECS deploys the application containers across the cluster.
- Before begin we need to create IAM role:

```bash
Use case : Elastic Container Service >>> Elastic Container Service task
Policy.  : AmazonECSTaskExecutionRolePolicy
Name     : ecsTaskExecutionRole
```

- From the Amazon ECS left navigation menu, select Task Definitions.

- Select Create new Task Definition.

- On the Configure task definition and containers page, do the following:

```yaml
Task Definition family: phonebook-mysql

Launch type: Fargate

Task size:
      CPU: .5 vCPU
      Memory: 1GB 

container-name: mysql

Image URI: mysql:5.7

Container Port: 3306

Protocol: TCP

App protocol: None

Environment variables:
      MYSQL_ROOT_PASSWORD: R1234r
      MYSQL_DATABASE: phonebook
      MYSQL_USER: admin
      MYSQL_PASSWORD: Oliver_1
```

- Click `create`.

- Your Task Definition is listed in the console.



### Deploy the database container as a service into the cluster.

- Navigate to the Amazon ECS console and select Clusters from the left menu bar.

- Select the `phonebook-cluster` cluster, select the Services tab then select Create.

```yaml
Capacity provider: FARGATE
Task definition Family: phonebook-mysql
Service name: phonebook-mysql-service
Desired tasks: 1
Service discovery:   # This part will create a private hosted zone named phonebook and `mysql.phonebook` record on the route53 service.
      Create a new namespace:
            Namespace name: phonebook # This will create AWS Cloud Map namespace
      Create a new service discovery service:
            Service discovery name: mysql # This will create an AWS Cloud Map service under AWS Cloud Map namespace phonebook.
```

- Click Create.


### Write a Task Definition for frontend

- From the Amazon ECS left navigation menu, select Task Definitions.

- Select Create new Task Definition.

- On the Configure task definition and containers page, do the following:

```yaml
Task Definition family: phonebook-frontend

Launch type: Fargate

Task size:
      CPU: .25 vCPU
      Memory: .5 GB 

container-name: phonebook

Image URI: clarusway/phonebook

Container Port: 80

Protocol: TCP

App protocol: HTTP

Environment variables:
      MYSQL_DATABASE_HOST: mysql.phonebook # This is A record on route53 service for phonebook-mysql-service tasks.
```

- Click `create`.

- Your Task Definition is listed in the console.


### Deploy the frontend container as a service into the cluster.

- Navigate to the Amazon ECS console and select Clusters from the left menu bar.

- Select the `phonebook-cluster` cluster, select the Services tab then select Create.

```yaml
Capacity provider: FARGATE
Task definition Family: phonebook-frontend
Service name: phonebook-frontend-service
Desired tasks: 1
Load balancing:
      Application Load Balancer: 
            Create a new load balancer:
            Load balancer name: phonebook-lb
```

- Click Create.



### Check your Application is Running.

- Navigate to the [Load Balancer section](https://console.aws.amazon.com/ec2/v2/home?#LoadBalancers:).

- Select `phonebook-lb` load balancer.

- In the Description field copy DNS name and paste the browser and see the application.