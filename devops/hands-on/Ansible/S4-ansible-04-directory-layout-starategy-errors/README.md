# Hands-on Ansible-04: Creating directory layout, error handling, and controlling execution with strategies in Ansible

The purpose of this hands-on training is to give students the knowledge of best practices in Ansible playbooks.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Explain how to create a directory layout using Ansible

- Explain how to handle errors in Ansible

- Explain how to control playbook execution in Ansible

## Outline

- Part 1 - Build the Infrastructure (3 EC2 Instances with Ubuntu 22.04 AMI)

- Part 2 - Install Ansible on the Controller Node

- Part 3 - Pinging the Target Nodes

- Part 4 - Install, Start, Enable MySQL, and Run The Phonebook App

- Part 5 - File separation

- Part 6 - Error Handling and Controlling playbook execution: strategies

## Part 1 - Build the Infrastructure

- Get to the AWS Console and spin-up 3 EC2 Instances with ```Ubuntu 22.04``` AMI.

- Configure the security groups as shown below:

  - Controller Node ----> Port 22 SSH

  - Target Node1 -------> Port 22 SSH, Port 3306 MYSQL/Aurora

  - Target Node2 -------> Port 22 SSH, Port 80 HTTP

## Part 2 - Install Ansible on the Controller Node

- Run the Terraform files in the github repo.

- Connect to your ```Controller Node```.

- Optionally, you can connect to your instances using VS Code.

- Check Ansible's installation using the command below.

```bash
$ ansible --version
```

- Show and explain the files (`ansible.cfg`, `inventory.ini`) that were created by Terraform.

## Part 3 - Pinging the Target Nodes

- Make a directory named ```ansible-lesson``` under the home directory and cd into it.

```bash
mkdir ansible-lesson
cd ansible-lesson
```

- Copy the phonebook app files (`phonebook-app.py`, `requirements.txt`, `init.sql`, `templates`) to the control node from your GitHub repository.

- Do not forget to change db server private IP in phonebook-app.py. (`app.config['MYSQL_DATABASE_HOST'] = "<db_server private ip>"`)

- Create a file named ```ping-playbook.yml``` and paste the content below.

```bash
touch ping-playbook.yml
```

```yml
- name: ping them all
  hosts: all
  tasks:
    - name: pinging
      ansible.builtin.ping:
```

- Run the command below to ping the servers.

```bash
ansible-playbook ping-playbook.yml
```

- Explain the output of the above command.

## Part 4 - Install, Start, Enable MySQL, and Run The Phonebook App.

- Create a playbook named `db_config.yml` and configure db_server.

```yml
- name: db configuration
  become: true
  hosts: db_server
  vars:
    hostname: cw_db_server
    db_name: phonebook_db
    db_table: phonebook
    db_user: remoteUser
    db_password: clarus1234

  tasks:
    - name: set hostname
      ansible.builtin.shell: "hostnamectl set-hostname {{ hostname }}"

    - name: Installing Mysql  and dependencies
      ansible.builtin.package:
        name: "{{ item }}"
        state: present
        update_cache: yes
      loop:
        - mysql-server
        - mysql-client
        - python3-mysqldb
        - libmysqlclient-dev

    - name: start and enable mysql service
      ansible.builtin.service:
        name: mysql
        state: started
        enabled: yes

    - name: creating mysql user
      community.mysql.mysql_user:
        name: "{{ db_user }}"
        password: "{{ db_password }}"
        priv: '*.*:ALL'
        host: '%'
        state: present

    - name: copy the sql script
      ansible.builtin.copy:
        src: /home/ubuntu/ansible-lesson/phonebook/init.sql
        dest: ~/

    - name: creating phonebook_db
      community.mysql.mysql_db:
        name: "{{ db_name }}"
        state: present

    - name: check if the database has the table
      ansible.builtin.shell: |
        echo "USE {{ db_name }}; show tables like '{{ db_table }}'; " | mysql
      register: resultOfShowTables

    - name: DEBUG
      ansible.builtin.debug:
        var: resultOfShowTables

    - name: Import database table
      community.mysql.mysql_db:
        name: "{{ db_name }}"   # This is the database schema name.
        state: import  # This module is not idempotent when the state property value is import.
        target: ~/init.sql # This script creates the products table.
      when: resultOfShowTables.stdout == "" # This line checks if the table is already imported. If so this task doesn't run.

    - name: Enable remote login to mysql
      ansible.builtin.lineinfile:
         path: /etc/mysql/mysql.conf.d/mysqld.cnf
         regexp: '^bind-address'
         line: 'bind-address = 0.0.0.0'
         backup: yes
      notify:
         - Restart mysql

  handlers:
    - name: Restart mysql
      ansible.builtin.service:
        name: mysql
        state: restarted
```

- Explain what these tasks and modules.

- Run the playbook.

```bash
ansible-playbook db_config.yml
```

- Open up a new Terminal or Window and connect to the ```db_server``` instance and check if ```MYSQL``` is installed, started, and enabled.

```bash
mysql --version
```

- Or, you can do it with an ad-hoc command.

```bash
ansible db_server -m shell -a "mysql --version"
```

- Create another playbook named `web_config.yml` and configure web_server.

```yml
- name: web server configuration
  hosts: web_server
  vars:
    hostname: cw_web_server
  tasks:
    - name: set hostname
      become: yes
      ansible.builtin.shell: "hostnamectl set-hostname {{ hostname }}"

    - name: Installing python for python app
      become: yes
      ansible.builtin.package:
        name:
          - python3
          - python3-pip
        state: present
        update_cache: yes

    - name: copy the app file to the web server
      ansible.builtin.copy:
        src: /home/ubuntu/ansible-lesson/phonebook/phonebook-app.py
        dest: ~/

    - name: copy the requirements file to the web server
      ansible.builtin.copy:
        src: /home/ubuntu/ansible-lesson/phonebook/requirements.txt
        dest: ~/

    - name: copy the templates folder to the web server
      ansible.builtin.copy:
        src: /home/ubuntu/ansible-lesson/phonebook/templates
        dest: ~/

    - name: install dependencies from requirements file
      become: yes
      ansible.builtin.pip:
        requirements: /home/ubuntu/requirements.txt

    - name: run the app
      become: yes
      ansible.builtin.shell: "nohup python3 phonebook-app.py &"
```

- Explain what these tasks and modules.

- Run the playbook.

```bash
ansible-playbook web_config.yml
```

- Check if you can see the website on your browser.


## Part-5 File separation

- We can assign variables to our groups and hosts.

- ``host_vars`` is a folder that you create and within the folder are YAML files which reference each specific target node.

- ``group_vars`` is also a folder you create, and within the folder are YAML files which reference groups of target nodes or all nodes.

- Both the Ansible ``host_vars`` directory and the ``group_vars`` directory have to be created manually and are not created by default.

- The names of the YAML files in ``group_vars`` must match the ``group`` defined in the ``inventory`` and also the YAML files in ``host_vars`` must be named exactly as the ``hosts`` in the ``inventory``.

- Create two directories `group_vars` and `host_vars` under the ```ansible-lesson``` directory.

```bash
mkdir group_vars host_vars
cd group_vars && touch servers.yml
cd ../host_vars && touch db_server.yml web_server.yml
```

- Next, create variables for the playbook under `servers.yml`

```yml
db_name: phonebook_db
db_table: phonebook
db_user: remoteUser
db_password: clarus1234
```

- Next, create variables for the playbook under `db_server.yml`

```yml
hostname: cw_db_server
```

- Next, create variables for the playbook under `web_server.yml`

```yml
hostname: cw_web_server
```

- We can run our tasks using ``ìnclude_tasks`` module in Ansible. `Ìnclude_tasks` includes a file with a list of tasks to be executed in the current playbook. So, now we will use two yml files to list our tasks.

- Create a directory `tasks` under the ```ansible-lesson``` directory.

```bash
cd ..
mkdir tasks && cd tasks && touch db_tasks.yml web_tasks.yml
```

- Paste the content below into the ```db_tasks.yml``` file.

```yml
    - name: set hostname
      ansible.builtin.shell: "sudo hostnamectl set-hostname {{ hostname }}"

    - name: Installing Mysql  and dependencies
      ansible.builtin.package:
        name: "{{ item }}"
        state: present
        update_cache: yes
      loop:
        - mysql-server
        - mysql-client
        - python3-mysqldb
        - libmysqlclient-dev

    - name: start and enable mysql service
      ansible.builtin.service:
        name: mysql
        state: started
        enabled: yes

    - name: creating mysql user
      community.mysql.mysql_user:
        name: "{{ db_user }}"
        password: "{{ db_password }}"
        priv: '*.*:ALL'
        host: '%'
        state: present

    - name: copy the sql script
      ansible.builtin.copy:
        src: /home/ubuntu/ansible-lesson/phonebook/init.sql
        dest: ~/

    - name: creating phonebook_db
      community.mysql.mysql_db:
        name: "{{ db_name }}"
        state: present

    - name: check if the database has the table
      ansible.builtin.shell: |
        echo "USE {{ db_name }}; show tables like '{{ db_table }}'; " | mysql
      register: resultOfShowTables

    - name: DEBUG
      ansible.builtin.debug:
        var: resultOfShowTables

    - name: Import database table
      community.mysql.mysql_db:
        name: "{{ db_name }}"   # This is the database schema name.
        state: import  # This module is not idempotent when the state property value is import.
        target: ~/init.sql # This script creates the products table.
      when: resultOfShowTables.stdout == "" # This line checks if the table is already imported. If so this task doesn't run.

    - name: Enable remote login to mysql
      ansible.builtin.lineinfile:
        path: /etc/mysql/mysql.conf.d/mysqld.cnf
        regexp: '^bind-address'
        line: 'bind-address = 0.0.0.0'
        backup: yes
      notify:
        - Restart mysql
```

- Paste the content below into the ```web_tasks.yml``` file.

```yml
    - name: set hostname
      ansible.builtin.shell: "sudo hostnamectl set-hostname {{ hostname }}"

    - name: Installing python for python app
      become: yes
      ansible.builtin.package:
        name:
          - python3
          - python3-pip
        state: present
        update_cache: yes

    - name: copy the app file to the web server
      ansible.builtin.copy:
        src: /home/ubuntu/ansible-lesson/phonebook/phonebook-app.py
        dest: ~/

    - name: copy the requirements file to the web server
      ansible.builtin.copy:
        src: /home/ubuntu/ansible-lesson/phonebook/requirements.txt
        dest: ~/

    - name: copy the templates folder to the web server
      ansible.builtin.copy:
        src: /home/ubuntu/ansible-lesson/phonebook/templates
        dest: ~/

    - name: install dependencies from requirements file
      become: yes
      ansible.builtin.pip:
        requirements: /home/ubuntu/requirements.txt

    - name: run the app
      become: yes
      ansible.builtin.shell: "nohup python3 phonebook-app.py &"
```

- Explain what these tasks and modules.

- Create a playbook named `playbook.yml` to run the application.

```yml
---
- name: run the db server
  hosts: db_server
  become: true
  tasks:
    - ansible.builtin.include_tasks: ./tasks/db_tasks.yml

  handlers:
    - name: Restart mysql
      ansible.builtin.service:
        name: mysql
        state: restarted

- name: run the web server
  hosts: web_server
  tasks:
    - ansible.builtin.include_tasks: ./tasks/web_tasks.yml
```

- Run the playbook.yaml

```bash
cd ..
ansible-playbook playbook.yml
```

- Check if you can see the website on your browser.

## Part-6 Error Handling and Controlling playbook execution: strategies

- Now, we create one more EC2 instance and add it to our inventory. (``amazon linux 2023, t2.micro``)

- Create a playbook (``playbook2.yml``) to learn Ansible playbook strategies and error handling.. 

```yml
---
- hosts: servers
 # any_errors_fatal: true
 # strategy: free
 # serial: 2
  tasks:
    - ansible.builtin.debug:
        msg: "task 1"

    - ansible.builtin.debug:
        msg: "task 2"

# our intention is to make node3 fail in the third task.
    - name: task 3
      become: true
      ansible.builtin.apt:
        name: git
        state: present
   #   ignore_errors: true

    - ansible.builtin.debug:
        msg: "task 4"

    - ansible.builtin.debug:
        msg: "task 5"
```

- Run the playbook.

```bash
ansible-playbook playbook2.yml
```

- In the playbook, we will get an ``error``, because we can not use `apt` module in node3 (amazon linux 2). So, the playbook can not complete for node3. If you want to stop the whole playbook when an error occurs in a target node, you can use `any_errors_fatal` parameter. Now, add the parameter `any_errors_fatal: true` after the `hosts` parameter and run the playbook again. 

```bash
ansible-playbook playbook2.yml
```

- We will see that the ``playbook stops when any task fail``.

- Then, add `ignore_errors: true` parameter inside the failed task and run the playbook again.

```bash
ansible-playbook playbook2.yml
```

- This time, we will see that the ``playbook ignores the third task and continues to playbook``.

- ``Strategy`` defines how a playbook is executed in Ansible. When Ansible runs, it runs each task across all servers in parallel at the same time. It waits for the task to finish on all servers before proceeding to the next task. This is the default behavior and is called ``linear strategy``.

- ``Free strategy ``: With the free strategy, unlike the default linear strategy, a host that is slow or stuck on a specific task won’t hold up the rest of the hosts and tasks.

- Now, first comment `any_errors_fatal: true` (Using any_errors_fatal with the free strategy is not supported, as tasks are executed independently on each host), next add the parameter ``strategy: free`` and run the playbook.

```bash
ansible-playbook playbook2.yml
```

- We will see that the tasks run non-parallel with `strategy: free` parameter.


- By default, Ansible runs each task on all hosts affected by a play before starting the next task on any host, using 5 forks. (By default, Ansible can create five forks at a time, and this is defined in the Ansible configuration file, ansible.cfg.) If you want to change this default behavior, you can use a different strategy plugin, change the number of forks, or apply one of several play-level keywords like ``serial``. This is not a separate strategy. This is based on the linear strategy, but you can control the number of servers executed at once or in a batch. In the playbook, we do not have a strategy option, so it uses a linear strategy by default. But there is a new option called serial, where you can specify how many servers you would like to process together.

- First, comment `strategy: free` and run the playbook without ``serial`` parameter, next run with this parameter (`serial: 2`) and see the differences between two execution.

```bash
ansible-playbook playbook2.yml
```

- We will see that the tasks work in pairs by target nodes.
