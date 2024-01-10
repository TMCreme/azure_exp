# Automate Azure Infrastructure and Application deployment with Terraform and Ansible

### Description
Using Terraform to create an Azure Virtual machine with all components and networking, then use Ansible to deploy a multi-tier web application (Backend, Frontend, Database, reverse proxy) to the virtual machine. 

### Running the code locally
* Ensure you have Terraform installed
* Ensure you have ansible installed as well (You can install ansible in a python virtual environment on Mac and Linux with `pip install ansible`)
* Change directory into the `automation` folder and run the following command to create an SSH key. We can use this since we are creating a Linux VM so it can help with running the ansible playbook.
```sh
    ssh-keygen -t rsa -b 2048 -f azuretestpem -q -N 
```
* NB: If in any case you are prompted for a passphrase, ignore and press Enter to proceed.
* Check the variables file and set the various variables, being the `subscription_id`, `tenant_id`, `client_id`, `client_secret` OR you can pass the variables to the `terraform apply` command below like this 
`terraform apply --var subscription_id="xxxxx" --var tenant_id="xxxxx" --var client_id="xxxx" --var client_secret="xxx" `
* From the root of the project, run the following commands in order to create the infrastructure
```sh
    terraform init
    terraform plan
    terraform apply
```
* When the infrastructure is done creating, there will be an output for the IP address of the virtual machine that has been created. 
* Copy that IP into the `automation/inventory.ini` file. This will serve as the host inventory for ansible to target
* Change directory into the `automation` folder and run the following command to create
```sh
    ansible-playbook -i inventory.ini -u testadmin --private-key=azuretestpem playbook.yml -e environment=Staging
```
* Deployment is done and the application should be running. Visit the live application on the IP address you got from the terraform output. 

### THE END