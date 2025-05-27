# Hands-on Maven-02: Dockerize a Maven Project

The purpose of this hands-on training is to teach the students how to dockerize a Maven Project.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Dockerize a Maven Project.

## Outline

- Part 1 - Launch Amazon Linux EC2 Instance with Cloudformation Template

- Part 2 - Run the Project

- Part 3 - Dockerize a Maven Project

- Part 4 - Prepare Kubernetes manifest files

## Part 1 - Launch Amazon Linux EC2 Instance and Connect with SSH

- Launch an EC2 instance using ```maven-java-template.yml``` file located in this folder.
    - This template will create an EC2 instance with Java-17 and Maven.

- Connect to your instance with SSH.

- Check if you can see the Maven's binary directory under ```/home/ec2-user/```.

- Run the command below to check if Java is available.

```bash
java -version
```

- Run the command below to check if the mvn commands are available.

```bash
mvn --version
```

## Part 2 - Run the Project

- Install git.

```bash
sudo dnf install git -y
```

- Fork the `https://github.com/spring-projects/spring-petclinic` repo to your repo and then clone it to your instance.

```bash
git clone https://github.com/<user-name>/spring-petclinic.git
```

- Run the command below to get the artifact under `sprinc-petclinic` folder.

```bash
mvn clean package
```

- Execute the following command to run the application under `sprinc-petclinic` folder.

```bash
java -jar target/*.jar
```

- Check the application at `<instance-ip>:8080` port.

- In its default configuration, Petclinic uses an `in-memory database (H2)` which gets populated at startup with data. In-memory databases are temporary and only last for the duration of the application's runtime. They are useful for development and testing.

- Stop the app (Ctrl + c).

- This time, we run the app with MySQL configuration. A similar setup is provided for MySQL if a persistent database configuration is needed. 

- Run a MySQL container for this app.

```bash
docker run --rm -d -e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic -p 3306:3306 mysql:9.1
```

> Note that whenever the database type changes, the app needs to run with a different profile: `spring.profiles.active=mysql` for MySQL.

- To activate `mysql spring.profile` run the following command.

```bash
export SPRING_PROFILES_ACTIVE=mysql
```

- Execute the following command to run the application under the `spring-petclinic` folder.

```bash
java -jar target/*.jar
```

- Check the `spring-petclinic/src/main/resources/application-mysql.properties` file for MySQL configuration.

```bash
# database init, supports mysql too
database=mysql
spring.datasource.url=${MYSQL_URL:jdbc:mysql://localhost/petclinic}
spring.datasource.username=${MYSQL_USER:petclinic}
spring.datasource.password=${MYSQL_PASS:petclinic}
# SQL is written to be idempotent, so this is safe
spring.sql.init.mode=always
```

- Check the MySQL database and see that the app is connected to the MySQL container.

```bash
docker container ls
docker exec -it mysql-server bash
mysql -upetclinic -ppetclinic
mysql> show databases;
mysql> use petclinic;
mysql> show tables;
mysql> select * from owners;
```

- Stop the app (Ctrl + c) and delete the `mysql` container.


## Part 3 - Dockerize a Maven Project

- This time we dockerize our app. By default, the petclinic app gets the database value according to `spring-petclinic/src/main/resources/application-mysql.properties` file.

```
spring.datasource.url=${MYSQL_URL:jdbc:mysql://localhost/petclinic}
```

- Change this line as below.

```
spring.datasource.url=${MYSQL_URL:jdbc:mysql://mysql-server/petclinic}
```

- Package the app again.

```bash
mvn clean package -DskipTests
```

- Create a Docker network named `petnet`

```bash
docker network create petnet
docker network ls
```

- Create the MySQL container in the `petnet` network.

```bash
docker run -d --rm --name mysql-server --net petnet -e MYSQL_USER=petclinic -e MYSQL_PASSWORD=petclinic -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=petclinic mysql:9.1
```

- Create a Dockerfile in the `/home/ec2-user` folder.

```Dockerfile
FROM maven:3.9.6-amazoncorretto-17 AS builder 
COPY .m2 /root/.m2
WORKDIR /app
COPY spring-petclinic .
RUN mvn clean package

FROM amazoncorretto:17-alpine3.18
WORKDIR /app
COPY --from=builder /app/target/spring-petclinic-3.4.0-SNAPSHOT.jar app.jar
ENV SPRING_PROFILES_ACTIVE mysql
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

- Build the Docker image.

```bash
docker build -t <docker-user-name>/petclinic .
```

- Run the app

```bash
docker run --rm --name petclinic --net petnet -p 8080:8080 clarusway/petclinic
```

- Check the application at `<instance-ip>:8080` port.

- Remove the containers.

```bash
docker rm -f petclinic mysql-server
```

- Create a `compose.yaml` file for the project in the `/home/ec2-user` folder.

```yaml
services:
  mysql-server:
    image: mysql:9.1
    environment:
      - MYSQL_ROOT_PASSWORD=Jj123456
      - MYSQL_USER=petclinic
      - MYSQL_PASSWORD=petclinic
      - MYSQL_DATABASE=petclinic
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3306"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
    networks:
      - petnet

  petclinic:
    image: clarusway/petclinic
    restart: always
    depends_on:
      mysql-server:
        condition: service_healthy
    ports:
      - "8080:8080"
    networks:
      - petnet

networks:
    petnet:
```

- Run the application.

```bash
docker-compose up
```

- Check the application at `<instance-ip>:8080` port.

- Remove the application.

```bash
docker-compose down
```

## Part 4 - Prepare Kubernetes manifest files

- Create a k8s folder.

```bash
mkdir k8s && cd k8s
```

- Create `mysql-deploy.yaml`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql-db
  template:
    metadata:
      labels:
        app: mysql-db
    spec:
      containers:
      - name: mysql-db
        image: mysql:8.2
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: Jj123456
        - name: MYSQL_USER
          value: petclinic 
        - name: MYSQL_PASSWORD
          value: petclinic
        - name: MYSQL_DATABASE
          value: petclinic
        resources: {}
```

- Create `mysql-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-server
  labels:
    name: mysql-server
spec:
  type: ClusterIP
  selector:
    app: mysql-db
  ports:
  - protocol: TCP
    port: 3306
    targetPort: 3306
```

- Create `petclinic-deploy.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: petclinic-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: petclinic
  template:
    metadata:
      labels:
        app: petclinic
    spec:
      containers:
      - name: petclinic
        image: clarusway/petclinic
        ports:
        - containerPort: 8080
```

- Create `petclinic-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: petclinic-service
  labels:
    name: petclinic
spec:
  type: NodePort
  selector:
    app: petclinic
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30001
```
