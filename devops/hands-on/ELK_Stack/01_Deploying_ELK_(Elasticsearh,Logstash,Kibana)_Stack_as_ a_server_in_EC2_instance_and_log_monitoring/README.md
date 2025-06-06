# Setting up ELK Stack (Elasticsearch Logstash Kibana Stack and Metricbeat) on Ubuntu 24.04 running on AWS EC2 Instances:

Purpose of the this hands-on training is to give students the knowledge of how to install, configure and use ELK Stack on Ubuntu 24.04 EC2 Instances.

## Steps:

* Create an EC2 instance.
* Install Java.
* Install Elasticseach.
* Install Metricbeat
* Install Logstash.
* Install Kibana.


### Create an EC2 instance:

If you are an absolute beginner, then follow these steps to create an EC2 instance. For a production environment, it is recommended to have at least three separate instances for each module. Otherwise, you can just create an EC2 with following configs,

* Ubuntu 24.04 or 18.04 LTS (64Bit x86).
* At least t3a.large.
* Storage 16GB.

### Security Group Configuration:

- I do recommend adding some tags because it will make your life easier with AWS resources. Next up is the security group config. To access Kibana dashboard we need to expose TCP port 5601. Default SSH one can be kept as it is. If you have a static public IP for your PC, make sure to limit the source to that IP.

### SSH Connection with EC2 İnstance:

-  Now you need to open a terminal if your local machine is Linux based or if you have a windows machine, I prefer the Git Bash because it will be easier to use with SSH.

-  Once you successfully SSH into the EC2 instance just execute ;

```bash
sudo apt-get update 
```

### Install Java

- Now we need to install Java. It is quite a straightforward installation. Just execute the command to get default-jre.

```bash
sudo apt-get install default-jre
```

- You can always check your Java version by executing the command `java -version` to make sure you have Java installed successfully.

### Install Elasticsearch

- Let’s install Elasticsearch as the first step towards completing our ELK stack. The installation process is fairly straightforward. Follow the next few steps. Add the repository key first,

```bash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
```

### Install the Apt Transport HTTPS because the default image does not contain that.

```bash
sudo apt-get install apt-transport-https
```

- Now run the following commands to complete the installation.

```bash
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
```

```bash
sudo apt-get update && sudo apt-get install elasticsearch
```

### Elastictic search config file configuration: 

- You have successfully installed Elasticsearch on your EC2 instance but we are not done yet. We need to check the config file now. Open the file, `/etc/elasticsearch/elasticsearch.yml` in your preferred editor (vim, vi). I recommend you to do this after you switch to superuser by executing `sudo su` command. Now you need to edit the config file as follows. The lines which are in white color letters are the changes to be done.

# ======================== Elasticsearch Configuration =========================
#
# NOTE: Elasticsearch comes with reasonable defaults for most settings.
#       Before you set out to tweak and tune the configuration, make sure you
#       understand what are you trying to accomplish and the consequences.
#
# The primary way of configuring a node is via this file. This template lists
# the most important settings you may want to configure for a production cluster.
#
# Please consult the documentation for further information on configuration options:
# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
#
# ---------------------------------- Cluster -----------------------------------
#
# Use a descriptive name for your cluster:
#
# cluster.name: my-application
#
# ------------------------------------ Node ------------------------------------
#
# Use a descriptive name for the node:
#
node.name: node-1
#
# Add custom attributes to the node:
#
# node.attr.rack: r1
#
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /var/lib/elasticsearch
#
# Path to log files:
#
path.logs: /var/log/elasticsearch
#
# ----------------------------------- Memory -----------------------------------
#
# Lock the memory on startup:
#
# bootstrap.memory_lock: true
#
# Make sure that the heap size is set to about half the memory available
# on the system and that the owner of the process is allowed to use this
# limit.
#
# Elasticsearch performs poorly when the system is swapping the memory.
#
# ---------------------------------- Network -----------------------------------
#
# Set the bind address to a specific IP (IPv4 or IPv6):
#
network.host: "localhost"
#
# Set a custom port for HTTP:
#
http.port: 9200
#
# For more information, consult the network module documentation.
#
# --------------------------------- Discovery ----------------------------------
#
# Pass an initial list of hosts to perform discovery when this node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
# discovery.seed_hosts: ["host1", "host2"]
#
# Bootstrap the cluster using an initial set of master-eligible nodes:
#
cluster.initial_master_nodes: ["node-1"]
#
# For more information, consult the discovery and cluster formation module documentation.
#
# ---------------------------------- Gateway -----------------------------------
#
# Block initial recovery after a full cluster restart until N nodes are started:
#
# gateway.recover_after_nodes: 3
#
# For more information, consult the gateway module documentation.
#
# ---------------------------------- Various -----------------------------------
#
# Require explicit names when deleting indices:
#
# action.destructive_requires_name: true

- To reach cluster with http request, comment following part in the same file.

```yaml
# Enable security features
# xpack.security.enabled: true

# xpack.security.enrollment.enabled: true

# Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
# xpack.security.http.ssl:
  # enabled: true
  # keystore.path: certs/http.p12

# Enable encryption and mutual authentication between cluster nodes
# xpack.security.transport.ssl:
  # enabled: true
  # verification_mode: certificate
  # keystore.path: certs/transport.p12
  # truststore.path: certs/transport.p12
# Create a new cluster with the current node only
# Additional nodes can still join the cluster later
# cluster.initial_master_nodes: ["ip-172-31-21-170"]

# Allow HTTP API connections from anywhere
# Connections are encrypted and require user authentication
# http.host: 0.0.0.0

# Allow other nodes to join the cluster from anywhere
# Connections are encrypted and mutually authenticated
#transport.host: 0.0.0.0

#----------------------- END SECURITY AUTO CONFIGURATION -------------------------
```

- Add following lines to `/etc/elasticsearch/elasticsearch.yml` to reach cluster with http request.

```yaml
xpack.security.enabled: false
xpack.security.enrollment.enabled: false
xpack.security.http.ssl.enabled: false
xpack.security.transport.ssl.enabled: false
```

-  You need to configure JVM heap size to be in the safe side when running the ElasticSearch. Since we are running an t3a.large instance, we will allocate 4GB as the heap size. Edit the file `/etc/elasticsearch/jvm.options` and enable the `-Xms4` lines. 

```
-Xms4g
-Xmx4g
```

### Now you are ready to start the Elasticseach service by executing,

```bash
sudo systemctl start elasticsearch
```

- After running the service, you can verify that your installation is working perfectly by executing a CURL command,

```bash
curl http://localhost:9200
```

### Install MetricBeat:

```bash
sudo apt-get install metricbeat
sudo systemctl start metricbeat
```

### Install Logstash

- Hey, you are almost there. Now moving on to next letter in the ELK stack. Just execute this command to install Logstash.

```bash
sudo apt-get install logstash
```

- Now create a sample file at the location `/home` named as `test_log.log` and include just a few lines for testing. Some content like,

````
72.132.86.148 - - [30/Mar/2020:00:00:05 +0000] "GET /item/books/2957 HTTP/1.1" 200 85 "/category/toys" "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"
204.39.102.110 - - [30/Mar/2020:00:00:10 +0000] "GET /category/electronics HTTP/1.1" 200 67 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1"
180.171.26.145 - - [30/Mar/2020:00:00:15 +0000] "GET /item/books/2957 HTTP/1.1" 200 85 "/category/books?from=0" "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; YTB730; GTB7.2; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET4.0C; .NET4.0E; Media Center PC 6.0)"
176.24.199.26 - - [30/Mar/2020:00:00:20 +0000] "GET /category/garden?from=10 HTTP/1.1" 200 130 "/item/electronics/3233" "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; YTB730; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)"
140.192.193.89 - - [30/Mar/2020:00:00:25 +0000] "GET /category/electronics HTTP/1.1" 200 51 "http://www.google.com/search?ie=UTF-8&q=google&sclient=psy-ab&q=Electronics+Music&oq=Electronics+Music&aq=f&aqi=g-vL1&aql=&pbx=1&bav=on.2,or.r_gc.r_pw.r_qf.,cf.osb&biw=4986&bih=109" "Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1"
184.213.228.52 - - [30/Mar/2020:00:00:30 +0000] "GET /category/games?from=0 HTTP/1.1" 200 69 "/category/games" "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; YTB730; GTB7.2; EasyBits GO v1.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)"
116.198.170.144 - - [30/Mar/2020:00:00:35 +0000] "GET /category/electronics HTTP/1.1" 200 122 "/item/music/1557" "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11"
44.90.187.34 - - [30/Mar/2020:00:00:40 +0000] "GET /category/finance HTTP/1.1" 200 125 "-" "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11"
196.60.49.217 - - [30/Mar/2020:00:00:45 +0000] "GET /category/giftcards HTTP/1.1" 200 119 "http://www.google.com/search?ie=UTF-8&q=google&sclient=psy-ab&q=Giftcards+Books&oq=Giftcards+Books&aq=f&aqi=g-vL1&aql=&pbx=1&bav=on.2,or.r_gc.r_pw.r_qf.,cf.osb&biw=2477&bih=449" "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; YTB730; GTB7.2; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET4.0C; .NET4.0E; Media Center PC 6.0)"
48.180.192.116 - - [30/Mar/2020:00:00:50 +0000] "GET /category/garden HTTP/1.1" 200 122 "/item/garden/2061" "Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1"
116.198.57.143 - - [30/Mar/2020:00:00:55 +0000] "GET /category/electronics HTTP/1.1" 200 73 "/item/toys/2367" "Mozilla/5.0 (iPad; CPU OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3"
176.168.129.139 - - [30/Mar/2020:00:01:00 +0000] "GET /category/networking?from=20 HTTP/1.1" 200 69 "-" "Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1"
140.45.44.120 - - [30/Mar/2020:00:01:05 +0000] "GET /item/software/2055 HTTP/1.1" 500 46 "-" "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; GTB7.2; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)"
24.228.172.209 - - [30/Mar/2020:00:01:10 +0000] "GET /item/electronics/1670 HTTP/1.1" 500 93 "http://www.google.com/search?ie=UTF-8&q=google&sclient=psy-ab&q=Electronics&oq=Electronics&aq=f&aqi=g-vL1&aql=&pbx=1&bav=on.2,or.r_gc.r_pw.r_qf.,cf.osb&biw=4899&bih=236" "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
````

- We need to create a config file for Logstash to test the installation. Create a file with `sudo vi /etc/logstash/conf.d/apache-01.conf` and include the following content into the file.

````
input {
        file {
                path => "/home/test_log.log"
                start_position => "beginning"
        }
}
output{
        elasticsearch {
                hosts => ["localhost:9200"]
        }
}
````

- You can start the Logstash service by running,

```bash
sudo systemctl start logstash
```

- And check if the config so far is running without error by executing this CURL command.

```bash
sudo curl -XGET 'localhost:9200/_cat/indices?v&pretty'
```

### Install Kibana:

- The last and most important part of the installation process. Execute the following command to install the Kibana dashboard.

```bash
sudo apt-get install kibana
```

- Now we need to configure Kibana to match our Elasticsearch search port and our EC2 opened port. Edit the config file using a preferred editor.

```bash
sudo vi /etc/kibana/kibana.yml
```

* * Make sure the white lines in the following config is changed.

# For more configuration options see the configuration guide for Kibana in
# https://www.elastic.co/guide/index.html

# =================== System: Kibana Server ===================
# Kibana is served by a back end server. This setting specifies the port to use.
server.port: 5601

# Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
# The default is 'localhost', which usually means remote machines will not be able to connect.
# To allow connections from remote users, set this parameter to a non-loopback address.
server.host: "0.0.0.0"

# Enables you to specify a path to mount Kibana at if you are running behind a proxy.
# Use the `server.rewriteBasePath` setting to tell Kibana if it should remove the basePath
# from requests it receives, and to prevent a deprecation warning at startup.
# This setting cannot end in a slash.
#server.basePath: ""

# Specifies whether Kibana should rewrite requests that are prefixed with
# `server.basePath` or require that they are rewritten by your reverse proxy.
# Defaults to `false`.
#server.rewriteBasePath: false

# Specifies the public URL at which Kibana is available for end users. If
# `server.basePath` is configured this URL should end with the same basePath.
#server.publicBaseUrl: ""

# The maximum payload size in bytes for incoming server requests.
#server.maxPayload: 1048576

# The Kibana server's name. This is used for display purposes.
#server.name: "your-hostname"

# =================== System: Kibana Server (Optional) ===================
# Enables SSL and paths to the PEM-format SSL certificate and SSL key files, respectively.
# These settings enable SSL for outgoing requests from the Kibana server to the browser.
#server.ssl.enabled: false
#server.ssl.certificate: /path/to/your/server.crt
#server.ssl.key: /path/to/your/server.key

# =================== System: Elasticsearch ===================
# The URLs of the Elasticsearch instances to use for all your queries.
elasticsearch.hosts: ["http://localhost:9200"]

# If your Elasticsearch is protected with basic authentication, these settings provide
# the username and password that the Kibana server uses to perform maintenance on the Kibana
# index at startup. Your Kibana users still need to authenticate with Elasticsearch, which
# is proxied through the Kibana server.


### Now start the Kibana service:

```bash
sudo systemctl start kibana
```

- Wait for like 30–45 seconds and visit your EC2 instance’s public IP with port 5601.

- You will be redirected to Kibana dashboard home.

* * * That’s all you have to do to have a running ELK stack on top of an AWS EC2 instance.