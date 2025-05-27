## Apache Reverse proxy and SSL certificate with certbot on NGINX
Purpose of the this hands-on training is to give the students basic knowledge of how to set reverse Nginx Web Server on Amazon Linux 2023 EC2 instance.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- demonstrate their knowledge of how to launch AWS EC2 Instance.

- establish a connection with AWS EC2 Instance with SSH.

- install the Nginx Server on Amazon Linux 2023 Instance.

- configure the Nginx Server to run simple HTML page.

- configure the Reverse Proxy


## Part 1 - Launching an Amazon Linux 2023 EC2 instance and Connect with SSH

- Launch 2 Amazon EC2 instances with AMI as `Amazon Linux 2023`, instance type as `t2.micro` and default VPC security group which allows connections from anywhere and any port. Give them a name as `Docker_prod`and `Reverse_proxy`.


## Part 2 - Installing and Configuring Nginx Proxy Web Server and Set 2 Docker container with different 

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

- Create 2 nginx container and 1 apache container and expose it on port 8081,8082 and 8083 respectively,

```bash
sudo docker run -d --name nginx1 -p 8081:80 nginx
sudo docker run -d --name nginx2 -p 8082:80 nginx
sudo docker run -d --name apache -p 8083:80 httpd
```


- To show load-balancing among containers;

```bash
sudo docker exec -it nginx1 /bin/bash
echo "<h1>1.container</h1>" > /usr/share/nginx/html/index.html
exit
```

```bash
sudo docker exec -it nginx2 /bin/bash
echo "<h1>2.container</h1>" > /usr/share/nginx/html/index.html
exit
```

- no need to change apache server's default page, it can be same.


- connect to the `Reverse_proxy` ec2 with ssh
```bash
ssh -i [Your Key pair] ec2-user@[Reverse_proxy EC2 IP / DNS name]
```

- Go to `/usr/share/nginx/html` folder.

```bash
cd /usr/share/nginx/html
```

- Go to Route53 and define A record between reverse.clarusway.us ----> Reverse Proxy Public IP adress.

- Check the "reverse.clarusway.us" to see default nginx page.


## Get SSL certificate with certbot and Reverse sent traffic https

- For installing Certbot and enabling HTTPS on NGINX, we will rely on Python. So, first of all, let's set up a virtual environment:


```bash
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
```

- Afterwards, run this command to install Certbot:

```bash
sudo /opt/certbot/bin/pip install certbot certbot-nginx
```

- Now, execute the following command to ensure that the certbot command can be run:

```bash
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
```

- Finally, run the following command to obtain a certificate and let Certbot automatically modify the NGINX configuration, enabling HTTPS:

```bash
sudo certbot --nginx
```

- Write your email
```bash
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel):
```

- Click yes

```bash
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o:
```

- Click whatever you want
```bash
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
```

- Your certificate has been addressed to dns.name.of.your.reverse.proxy
```bash
Account registered.
Requesting a certificate for www.serkangumus.me
Performing the following challenges:
http-01 challenge for www.serkangumus.me
Waiting for verification...
Cleaning up challenges
Deploying Certificate to VirtualHost /etc/nginx/nginx.conf
Redirecting all traffic on port 80 to ssl in /etc/nginx/nginx.conf

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations! You have successfully enabled https://www.serkangumus.me
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/nginx.blue-tulip.org/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/nginx.blue-tulip.org/privkey.pem
   Your certificate will expire on 2021-05-01. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again with the "certonly" option. To non-interactively
   renew *all* of your certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

- If you test your server using the SSL Labs Server Test now, it will only get a B grade due to weak Diffie-Hellman parameters. This affects the security of the initial key exchange between our server and its users. We can fix this by creating a new dhparam.pem file and add it to our server block.

- This command generates a Diffie-Hellman (DH) parameter file using OpenSSL and saves it to the specified directory. DH parameters facilitate secure key exchange in cryptographic protocols like SSL/TLS.

- Create the file using openssl:

```bash
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

- Paste the following line anywhere within the server block "/etc/nginx/nginx.conf"

```bash
ssl_dhparam /etc/ssl/certs/dhparam.pem;
```

- Save the file and quit your editor, then verify the configuration:
```bash
sudo nginx -t
```

If you have no errors, reload Nginx:

```bash
sudo systemctl reload nginx
```


## Install Certbot

- Let’s Encrypt’s certificates are only valid for ninety days. This is to encourage users to automate their certificate renewal process. We’ll need to set up a regularly run command to check for expiring certificates and renew them automatically.

To run the renewal check daily, we will use cron, a standard system service for running periodic jobs. We tell cron what to do by opening and editing a file called a crontab.

```bash
sudo crontab -e
```

- Your text editor will open the default crontab which is an empty text file at this point. Paste in the following line, then save and close it:
The 15 3 * * * part of this line means “run the following command at 3:15 am, every day”. You may choose any time.
The renew command for Certbot will check all certificates installed on the system and update any that are set to expire in less than thirty days. --quiet tells Certbot not to output information or wait for user input.

cron will now run this command daily. All installed certificates will be automatically renewed and reloaded when they have thirty days or less before they expire.
```bash
15 3 * * * /usr/bin/certbot renew --quiet
```


- To redirect traffic from ports to the path, we are going to set config files. Lets open the `nginx.conf` file to the /etc/nginx/nginx.conf

```text
vi /etc/nginx/nginx.conf
```

- Like this application conf files are very important and we might change unpurposely while we are doing something. That's why different files are also accepted as config files and if we change something on the configuration, we don't touch the main file and we are going to create new config files instead of the main config file.

- Certbot displays the Common Name and Subject Alternative Name (SAN) that you provided in the VirtualHost block. Select assigned DNS to IP address. `/etc/nginx/nginx.conf` is the main file and we should our config files within `/etc/nginx/conf.d`

```text
cd /etc/nginx/conf.d
```

Let's create a redirect conf file named `redirect.conf`

```text
vi redirect.conf
```

- To redirect traffic on ports 8081, 8082, and 8083 to show load-balancing

```bash

server {
    if ($host = reverse.clarusway.us) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    # To redirect from HTTP to HTTPS
    listen 80;
    server_name reverse.clarusway.us;

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    # Load Balancing over HTTPS
    listen 443 ssl;
    server_name reverse.clarusway.us;
    ssl_certificate /etc/letsencrypt/live/reverse.clarusway.us/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/reverse.clarusway.us/privkey.pem; # managed by Certbot

    # Load Balancing
    location / {
        proxy_pass http://myapp;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Definen upstream for load-balancing
# IP addresses in the upstream myapp block should be public IP of the "docker_prod" instance.
upstream myapp {
    server 100.26.211.133:8081;
    server 100.26.211.133:8082;
    server 100.26.211.133:8083;
}

```

- Restart the nginx

```bash
sudo systemctl restart nginx
```

- try connecting to reverse.clarusway.us on the browser and you will see the application respectively and load-balancing.

```bash
reverse.clarusway.us
```

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html#letsencrypt
