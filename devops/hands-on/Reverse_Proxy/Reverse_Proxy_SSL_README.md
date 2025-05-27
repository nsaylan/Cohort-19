## Apache Reverse proxy and SSL certificate with certbot
Purpose of the this hands-on training is to give the students basic knowledge of how to set reverse Apache Web Server on Amazon Linux 2023 EC2 instance.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- demonstrate their knowledge of how to launch AWS EC2 Instance.

- establish a connection with AWS EC2 Instance with SSH.

- install the Apache Server on Amazon Linux 2023 Instance.

- configure the Apache Server to run simple HTML page.

- configure the Reverse Proxy


## Part 1 - Launching an Amazon Linux 2023 EC2 instance and Connect with SSH

- Launch 2 Amazon EC2 instances with AMI as `Amazon Linux 2023`, instance type as `t2.micro` and default VPC security group which allows connections from anywhere and any port. Give them a name as `Docker_prod` and`Reverse_proxy`


## Part 2 - Installing and Configuring Apache Proxy Web Server and Main Web server to Run a Simple Web Page

- Connect to your `Docker_prod` instance with SSH.

```bash
ssh -i [Your Key pair] ec2-user@[Docker_prod EC2 IP / DNS name]
```

- Install Docker

```bash
sudo dnf update -y
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
newgrp docker
docker --version
```

- Create nginx container and expose it on port 8081

```bash
sudo docker run -d --name nginx -p 8081:80 nginx
```

- Connect to the `Reverse_proxy` ec2 with SSH.

```bash
ssh -i [Your Key pair] ec2-user@[Reverse_proxy EC2 IP / DNS name]
```

- Install the Apache Web Server.

```bash
sudo dnf update -y
sudo dnf install httpd -y
```

- Start the Apache Web Server.

```bash
sudo systemctl start httpd
sudo systemctl enable httpd
```

- Go to `/var/www/html` folder.

```bash
cd /var/www/html
```

- Show content of folder.

```bash
ls
```

- Add simply `index.html`.

```bash
sudo vim index.html
```


```html
<html>
    <head>
        <title>Welcome to My Blog!</title>
    </head>
    <body>
        <h1>Success! Our first website is working!</h1>
    </body>
</html>

```

- Go to Route53 and define A record between clarusway.us ----> Reverse Proxy public IP adress

- Check the "clarusway.us" to see content.


## Reverse sent traffic https with certbot

- Navigate to your home directory (/home/ec2-user). Download EPEL using the following command.

```bash
sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

- Install the repository packages as shown in the following command.
```bash

sudo rpm -ihv --nodeps ./epel-release-latest-8.noarch.rpm
```

- Go to `/etc/httpd/conf/httpd.conf` and show the file with vi. Show `IncludeOptional conf.d/*.conf` at the end of the file. This give us an oportunity to create our conf files under the conf.d/*.conf. Best practice do not touch this `/etc/httpd/conf/httpd.conf` file. We create our file

```bash
vi /etc/httpd/conf/httpd.conf
```

- Go to `/etc/httpd/conf.d` file and create our *.conf file like clarus.conf and write inside as below

```bash
sudo vim clarus.conf

<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName "clarusway.us"
</VirtualHost>
```

- Reload or Restart apache server
```bash
sudo systemctl stop httpd
sudo systemctl start httpd
```


## Install Certbot

- Install Certbot packages and dependencies using the following command.

```bash

sudo dnf install -y augeas-libs
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot
sudo dnf install certbot python3-certbot-apache -y
```

- Run Certbot.

```bash
sudo certbot
```

- At the prompt "Enter email address (used for urgent renewal and security notices)," enter a contact address and press Enter.

- Agree to the Let's Encrypt Terms of Service at the prompt. Enter "Y" and press Enter to proceed.
```text

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.4-April-3-2024.pdf. You must agree in
order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: 

```

- At the authorization for EFF to put you on their mailing list, enter "Y" or "N" and press Enter.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: 


- Certbot displays the Common Name and Subject Alternative Name (SAN) that you provided in the VirtualHost block. Select assigned DNS to IP address

```text
Which names would you like to activate HTTPS for?
We recommend selecting either all domains, or all domains in a VirtualHost/server block.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: clarusway.us
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel): 
```

-   Certbot completes the configuration of Apache and reports success and other information.

```text

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/clarusway.us/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/clarusway.us/privkey.pem
This certificate expires on 2024-11-06.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

Deploying certificate
Successfully deployed certificate for clarusway.us to /etc/httpd/conf.d/clarus-le-ssl.conf
Congratulations! You have successfully enabled HTTPS on https://clarusway.us
We were unable to subscribe you the EFF mailing list because your e-mail address appears to be invalid. You can try again later by visiting https://act.eff.org.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

- try DNS to the browser and we can see that it redirects traffic from http to https

- Go to `etc/httpd/conf.d` and see the new file that is created after configuring certbot named "clarus-le-ssl.conf" and open it with vi editor

- ProxyPass and ProxyPassReverse lines as shown below. Reverse proxy redirect traffic come through `clarusway.us` to `http://172.31.23.128:8081/` (This is second ec2 that has our real website on port 8081)
```bash
<IfModule mod_ssl.c>
<VirtualHost *:443>
    DocumentRoot "/var/www/html"
    ServerName "clarusway.us"
SSLCertificateFile /etc/letsencrypt/live/clarusway.us/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/clarusway.us/privkey.pem
Include /etc/letsencrypt/options-ssl-apache.conf
         ProxyPass  / http://172.31.23.128:8081/
         ProxyPassReverse / http://172.31.23.128:8081/
</VirtualHost>
</IfModule>
```

- to redirect traffic to the `clarusway.us` go to the `clarus.conf` change it as below
```bash
<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName "clarusway.us"
    Redirect permanent / https://clarusway.us/
</VirtualHost>
```


- Reload or Restart apache server
```bash
sudo systemctl stop httpd
sudo systemctl start httpd
```
- Check the web browser "clarusway.us" to see Nginx Web Server.


https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html#letsencrypt