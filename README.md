
#  What is this

Technically speaking this is just me playing around with terraform and ansible as I need to learn it for work. I have used it before work, but not enough to be comfortable with it.

This project will allow you to spin up a Bookstack instance for around $3 per month, but google will shutdown the vm instance randomly as it is preemtible. You can just write a healthcheck script for that.

# What you will need

 - [ ] Terraform on your computer
 - [ ] ansible on your computer
 - [ ] ability to read my jumbled mess

[How to install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) 

 [How to install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 

 If my instructions are really that bad, you can find a youtube video.
# How to use

Clone this to your computer 
```
git clone https://github.com/userbradley/bookstack-ansible.git 
```
# Something to know
You dont need to use terraform for this. You can just create a digital ocean droplet, a linode vm, a we definitely wont spy on your data vm on tencent cloud, or alibaba cloud if you fancy sharing your KB articles with china. Your choice.
If you chose not to use terraform, skip to `How to Ansible this` 

# Terraform route
Now that you have this downloaded, you will want to create a GCP account. Just go to cloud.google.com and sign up. You should be able to get a free tier. It usually lasts a year of to $300, which ever comes first.

Once there, you will need to create a service account by clicking the 3 lines at the top left, scroll down to `Iam & admin` then click service accounts. 
Click `Create Service account` at the top of the page, and name it something like `terraform-service-account` and click `create` 
Here you will need to  `select a role` and please pick `compute admin` then click `continue` followed by `done`

Click your service account and scroll down to where you see `keys` on the page.
Click `ADD KEY` and select `json` 
Download the file to the terraform folder of the repo you cloned earlier and edit the file called `provider.tf` and put the file name where you see it asking for it. 

Copy your `id_rsa.pub` file to the terraform directory 
```
cp ~/.ssh/id_rsap.pub bookstack-ansible/terraform/id_rsa.pub
```
In the `main.tf` file, scroll down to the bottm and replace `username` with your username from the SSH key.

Open a shell window and type `terraform init` 
this *should* download the google dependencies needed to create vm's on GCP. 
Once that's done, you will need to run
```
terraform apply
```
If you're lazy (like me) and dont want to type `yes`
```
echo "yes" | terraform apply
```

It will spin up an ubuntu VM in `us-central1-c` if memory serves correctly.

if you want to spin one up closer to home, check [here](https://bookstack.breadnet.co.uk/books/automation/page/building-infrastructure-9b8) where I have a list of regions and their locations. Probably better to use google's official page. 



Once Terraform has done it's business and created an instance, grab it's ip address from the google console.
> just want to add I am still bad a terraform so i cant quite figure out a way to get the IP address though terraform but when i do you'll see a new update

ssh to the ip address
```
ssh <ip>
```
If prompted, type yes.

In google console, create a firewall rule allowing port 80 and 443.
Click `compute engine` from the nav bar, click your instance name, scroll down to `networking` then click `details`
On the left, click`firewall` and `CREATE FIREWALL RULE` 
Name it `allow http`, targets `apply to all` and then ip filter is `0.0.0.0/0` and select tcp then type `80,443` and then save

# How to Ansible this

Now that we have the node, we can create the actual fluff. 

Change directory to the ansible folder 
```
cd ../ansible
```
Assuming you were in the terraform folder

Here, we will need to edit the file called `hosts` 

Add the IP address of your google node or what ever node where is asks.

Now we need to edit the file `group_vars/booknodes.yml`

Here we need to specify a few things:

| Value name | what  | Explain | 
|--|--|--|
|  mysql_root_password|Pick a strong password, use a password manager  |We need a root password for database admin should we need to login manually|
| mysql_db| this can stay as default but if you want to change the name of your database, then here you can do it. | we need to specify a database for Bookstack to use for storing data
|mysql_user | we can leave this as default | it's not meant to be spelt right as people will just try and brute force the `bookstack` name. you can call it Jeff if you want
| mysql_password | This is the password Bookstack will auth with | We need to change this so that Bookstack can auth with the database. 
|url | base URL for your bookstack instance | You can make it `book.stack.com` if you own that domain. I suggest going with something like `bookstack.yourdomain.tld` 
|domain | Your base domain without the subdomain | It's used for the email settings should you use it
|bookstack_name | Call it jeff| This is what your bookstack instance will be called
|protocal | http or https | In the .env file we need an app url. if you are going to add a cert later, this will need to be set as https
|mail_driver | smtp, mail or sendmail | this is what you will use to send emails from bookstack. You can leave this blank
|mail_server | address or IP of your email server | See above
|mail_port | The port bookstack will connect to the mail server over | usually left as port 25 for smpt
| mail_username | The username you auth to the server with | some mail providers dont require you to auth with them, but this is where you would put that info
| mail_password | similar to above | Please dont make me explain this

Example looks like this:
``` 
#Database stuff
mysql_root_password: "WubbaLubbaDubDub"
mysql_db: "bookstack"
mysql_user: "boockstack"
mysql_password: "HolyguacamoleThisPasswordIsInsecure"

#Setup stuff for bookstack and nginx
url: "bookstack.breadnet.co.uk" 
domain: "breadnet.co.uk" 
bookstack_name: "breadStack"  
protocal: "http"  #http or https

#Bookstack mail specifics
mail_driver: "smtp"  
mail_server: "mail.bread"  
mail_port: "25"  
mail_username: ""  
mail_password: ""  
```
I will also add that if your mail server is the local host.. put `localhost`

Now that that's all good, we can run the script. In the ansible folder run
```
ansible-playbook -l bookstack -i hosts -u <server login username> bookstack.yml
```
Where `-l` is the host name under the `hosts` file, `-i` tells ansible what inventory file to use and `-u` tells ansible what user to login as then finally `bookstack.yml` is the playbook to run.

Once it's done, you will need to add a DNS record pointing to the GCP compute node and then open http://<your bookstack> and login with `admin@admin.com` and the password being `password`

# If anything is wrong
Please make a pull request if anything is messed up, or open an issue if you need help.

# To do

 - [ ] Add ability to use nginx basic auth
 - [ ] Add ability to run certbot to get free LE certificate
 - [ ] Add ability to create UFW rules
 - [ ] Create monitor script to restart the node if it goes down
 - [ ] Add a backup script that dumps the database as a cronjob
 - [ ] Learn to write choerent sentences 

