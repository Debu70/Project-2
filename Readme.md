## 🏗️ Terraform Infrastructure Provisioning

Terraform is used in this project to provision the AWS infrastructure required for the two-EC2 architecture.

Instead of manually creating EC2 instances from the AWS Console, Terraform defines the infrastructure as code and creates the resources in a repeatable and consistent way.

### Terraform Architecture

```text
                    Terraform
                        │
                        │ AWS Provider
                        ▼
                  ┌─────────────┐
                  │     AWS     │
                  └──────┬──────┘
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
      ┌───────────────┐     ┌──────────────────┐
      │ Bastion EC2   │     │ Application EC2  │
      │               │     │                  │
      │ t3.micro      │     │ m7i-flex.large   │
      │ Public Subnet │     │ Private Subnet   │
      │ SSH :22       │────▶│ SSH :22          │
      └───────────────┘     │ Docker / Nginx   │
                            │ Website :80      │
                            └──────────────────┘
```

### 🎯 What Terraform Creates

The Terraform configuration is designed to provision two EC2 instances:

| Resource           | Purpose                        | Instance Type    | Network        |
| ------------------ | ------------------------------ | ---------------- | -------------- |
| Bastion Server     | Secure administrative access   | `t3.micro`       | Public subnet  |
| Application Server | Hosts Docker/Nginx application | `m7i-flex.large` | Private subnet |

The infrastructure can be recreated using the same Terraform configuration instead of manually creating each EC2 instance.

---

## 📁 Terraform Project Structure

Example Terraform project structure:

```text
Terraform-2-EC2/
│
├── version.tf
├── provider.tf
├── data.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
└── output.tf
```

### `version.tf`

Defines the Terraform and AWS provider requirements.

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

### `provider.tf`

Configures Terraform to communicate with AWS.

```hcl
provider "aws" {
  region = var.region
}
```

### `data.tf`

Retrieves the latest suitable Amazon Linux 2023 AMI instead of hardcoding an AMI ID.

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
```

### `variables.tf`

Defines reusable Terraform variables such as AWS region, key pair, instance types, and instance names.

```hcl
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types"
  type        = list(string)

  default = [
    "t3.micro",
    "m7i-flex.large"
  ]
}

variable "instance_names" {
  description = "EC2 instance names"
  type        = list(string)

  default = [
    "bastion-server",
    "app-server"
  ]
}
```

### `terraform.tfvars`

Contains environment-specific values.

```hcl
region = "ap-south-1"

key_name = "<YOUR_EC2_KEY_PAIR>"

instance_types = [
  "t3.micro",
  "m7i-flex.large"
]

instance_names = [
  "bastion-server",
  "app-server"
]
```

> ⚠️ Never commit private keys, AWS access keys, passwords, tokens, or other sensitive information to GitHub.

---

# 🔄 Terraform Workflow

Terraform follows a declarative Infrastructure as Code workflow.

```text
┌─────────────┐
│ Write .tf   │
│ files       │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ terraform   │
│ init        │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ terraform   │
│ fmt         │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ terraform   │
│ validate    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ terraform   │
│ plan        │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ terraform   │
│ apply       │
└──────┬──────┘
       │
       ▼
┌────────────────────┐
│ AWS Infrastructure │
└────────────────────┘
```

### 1. Terraform Init

Initializes the Terraform working directory and downloads the required providers.

```bash
terraform init
```

Example:

```text
Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/aws...
Terraform has been successfully initialized!
```

---

### 2. Terraform Format

Formats Terraform configuration files according to standard Terraform syntax.

```bash
terraform fmt
```

To format all Terraform files recursively:

```bash
terraform fmt -recursive
```

---

### 3. Terraform Validate

Checks whether the Terraform configuration is syntactically valid and internally consistent.

```bash
terraform validate
```

Expected:

```text
Success! The configuration is valid.
```

---

### 4. Terraform Plan

Creates an execution plan showing what Terraform intends to create, modify, or destroy.

```bash
terraform plan
```

Typical output:

```text
Plan: 2 to add, 0 to change, 0 to destroy.
```

This step is useful for reviewing infrastructure changes before actually applying them.

---

### 5. Terraform Apply

Creates or updates the AWS infrastructure.

```bash
terraform apply
```

Terraform displays the proposed changes and asks for confirmation.

```text
Do you want to perform these actions?

  Enter a value: yes
```

For automated/lab environments:

```bash
terraform apply -auto-approve
```

---

### 6. Terraform Output

Displays values defined in `output.tf`, such as instance IDs and IP addresses.

```bash
terraform output
```

For a specific output:

```bash
terraform output bastion_public_ip
```

Example:

```text
"xx.xx.xx.xx"
```

> Use placeholders in documentation. Do not publish real public/private IP addresses if they are part of your live infrastructure.

---

### 7. Terraform Show

Displays the current Terraform-managed infrastructure state.

```bash
terraform show
```

This can be useful for inspecting resources that Terraform currently manages.

---

### 8. Terraform State List

Shows resources currently tracked by Terraform.

```bash
terraform state list
```

Example:

```text
aws_instance.bastion
aws_instance.app
```

---

### 9. Terraform Refresh / Plan

Terraform compares the configuration and current infrastructure state when creating a plan.

```bash
terraform plan
```

This helps identify infrastructure drift or configuration changes.

---

### 10. Terraform Destroy

Removes resources managed by Terraform.

```bash
terraform destroy
```

Terraform asks for confirmation before deleting the infrastructure.

For automated environments:

```bash
terraform destroy -auto-approve
```

> ⚠️ `terraform destroy` can delete production infrastructure. Always review the plan and target the correct AWS account/environment.

---

# 🧩 Terraform CLI Quick Reference

| Command                | Purpose                        |
| ---------------------- | ------------------------------ |
| `terraform init`       | Initialize Terraform           |
| `terraform fmt`        | Format `.tf` files             |
| `terraform validate`   | Validate configuration         |
| `terraform plan`       | Preview infrastructure changes |
| `terraform apply`      | Create/update infrastructure   |
| `terraform output`     | Display outputs                |
| `terraform show`       | Display Terraform state        |
| `terraform state list` | List managed resources         |
| `terraform destroy`    | Delete managed infrastructure  |

### Typical Deployment Sequence

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
```

---

# 🔐 Terraform and Security

The Terraform configuration should follow the same security principles as the manually configured architecture.

### Bastion Security Group

```text
Inbound:

SSH :22
Source: <ADMIN_PUBLIC_IP>/32
```

Only the administrator's public IP should be allowed to access SSH where practical.

### Application Security Group

```text
Inbound:

SSH :22
Source: <BASTION_SECURITY_GROUP>

HTTP :80
Source: <ALB_SECURITY_GROUP>
```

For temporary lab testing through the Bastion:

```text
TCP :1256
Source: <BASTION_SECURITY_GROUP>
```

The application server should not expose SSH or application ports unnecessarily to:

```text
0.0.0.0/0
```

---

# 🔑 Terraform Secrets and Sensitive Files

Do not commit the following to GitHub:

```text
*.pem
*.key
.env
terraform.tfstate
terraform.tfstate.*
.terraform/
```

Example `.gitignore`:

```gitignore
# Terraform
.terraform/
terraform.tfstate
terraform.tfstate.*
*.tfstate
*.tfstate.*

# Sensitive files
*.pem
*.key
.env

# Terraform variable files if they contain secrets
terraform.tfvars
*.auto.tfvars
```

If `terraform.tfvars` contains only non-sensitive configuration, it may be version-controlled according to the project's requirements. However, never commit credentials or secrets.

---

# 🔗 Infrastructure → Application Deployment

Terraform is responsible for **infrastructure provisioning**, while Docker and Nginx are responsible for **application deployment and serving**.

```text
                Terraform
                    │
                    ▼
          ┌──────────────────┐
          │ AWS Infrastructure│
          └────────┬─────────┘
                   │
          ┌────────┴────────┐
          ▼                 ▼
     Bastion EC2       Application EC2
          │                 │
          │ SSH             │
          └────────────────▶│
                            │
                         Docker
                            │
                            ▼
                          Nginx
                            │
                            ▼
                       HTML / CSS
                         Website
```

### Responsibility Breakdown

| Technology      | Responsibility                        |
| --------------- | ------------------------------------- |
| Terraform       | Infrastructure provisioning           |
| AWS             | Cloud infrastructure                  |
| EC2             | Compute servers                       |
| Security Groups | Network access control                |
| SSH             | Secure administration                 |
| Bastion         | Controlled administrative entry point |
| Git/GitHub      | Source-code management                |
| Docker          | Application containerization          |
| Nginx           | Web server                            |
| HTML/CSS        | Website                               |

This separation makes the project easier to understand and allows infrastructure and application deployment to evolve independently.

---

# 🚀 Complete Infrastructure Deployment Flow

```text
Developer
    │
    │ Terraform CLI
    ▼
Terraform Configuration
    │
    ├── Provider
    ├── AMI Data
    ├── Variables
    ├── EC2
    ├── Security Groups
    └── Outputs
    │
    ▼
AWS
    │
    ├───────────────┐
    ▼               ▼
Bastion EC2      App EC2
Public Subnet   Private Subnet
    │               │
    │ SSH           │
    └──────────────▶│
                    │
                    ▼
                  Docker
                    │
                    ▼
                  Nginx
                    │
                    ▼
              Static Website
```

---

## 📌 Project Summary

This project demonstrates a practical AWS DevOps workflow combining:

```text
Terraform
   ↓
AWS Infrastructure
   ↓
EC2 Bastion + Private App Server
   ↓
Security Groups
   ↓
SSH / Agent Forwarding
   ↓
Git / GitHub
   ↓
Docker
   ↓
Nginx
   ↓
HTML/CSS Website
```

The infrastructure is provisioned using **Terraform**, administrative access is controlled through a **Bastion Host**, and the application is containerized using **Docker** and served through **Nginx** on the private Application Server.

For a production implementation, the application can be placed behind an **Application Load Balancer (ALB)** while keeping the application instances private.

---

## ⭐ Key DevOps Concepts Demonstrated

* Infrastructure as Code (IaC)
* Terraform provider and resources
* Terraform variables and outputs
* Terraform state
* Terraform plan/apply workflow
* AWS EC2
* Public and private networking
* Security Groups
* Bastion Host
* SSH Agent Forwarding
* Git/GitHub
* Docker containerization
* Nginx web server
* Static website deployment
* Infrastructure and application separation
* Basic cloud security practices

---

# 🚀 AWS EC2 Bastion Host + Private Application Server

A production-oriented AWS deployment project demonstrating how to securely host a static website on a **private EC2 instance** using **Docker and Nginx**, while accessing and managing the private server through an **EC2 Bastion/Jump Server**.

The project uses two EC2 instances:

* 🛡️ **Bastion / Jump Server** — Publicly accessible and used for secure SSH access
* 🖥️ **Application Server** — Private EC2 instance running the website inside a Docker container
* 🐳 **Docker** — Container runtime
* 🌐 **Nginx** — Web server serving the static website

---

## 🏗️ Architecture

```text
                              🌍 Internet
                                  │
                                  │ SSH :22
                                  ▼
                       ┌─────────────────────┐
                       │   🛡️ Bastion Host   │
                       │      EC2 Instance   │
                       │                     │
                       │ Public Subnet       │
                       │ Public IP            │
                       │ SSH Access           │
                       └──────────┬──────────┘
                                  │
                         SSH :22  │
                                  │
                                  ▼
                ┌─────────────────────────────────┐
                │      🔒 Private Subnet          │
                │                                 │
                │  ┌───────────────────────────┐  │
                │  │ 🖥️ Application Server     │  │
                │  │       EC2 Instance        │  │
                │  │                           │  │
                │  │   🐳 Docker               │  │
                │  │      │                    │  │
                │  │      ▼                    │  │
                │  │   🌐 Nginx :80            │  │
                │  │      │                    │  │
                │  │      ▼                    │  │
                │  │   📄 Static Website       │  │
                │  └───────────────────────────┘  │
                └─────────────────────────────────┘
```

### 🔄 Request / Access Flow

```text
Developer Laptop
       │
       │ SSH
       ▼
🛡️ Bastion EC2
       │
       │ Private IP / SSH
       ▼
🖥️ Application EC2
       │
       ▼
🐳 Docker Container
       │
       ▼
🌐 Nginx
       │
       ▼
📄 HTML / CSS Website
```

---

# 📌 Project Overview

The objective of this project is to demonstrate a secure two-server AWS architecture.

Instead of assigning a public IP directly to the application server, the application server is placed in a private network and accessed through a Bastion Host.

This provides a basic implementation of the following enterprise concept:

> **Public access layer → Bastion → Private application infrastructure**

The website is packaged into a Docker image and served using Nginx.

---

# ☁️ AWS Infrastructure

## EC2 Instance 1 — Bastion / Jump Server 🛡️

Purpose:

* Secure SSH entry point
* Access point for private EC2 instances
* Administrative operations
* SSH agent forwarding
* Deployment management

Recommended configuration:

| Configuration | Value               |
| ------------- | ------------------- |
| Instance Type | `t3.micro`          |
| Subnet        | Public Subnet       |
| Public IP     | Required            |
| OS            | Amazon Linux 2023   |
| SSH Port      | `22`                |
| Role          | Bastion / Jump Host |

The Bastion server should contain only the tools required for administration.

---

# 🖥️ EC2 Instance 2 — Application Server

Purpose:

* Run the application
* Run Docker
* Host the Nginx container
* Serve the static website

Recommended configuration:

| Configuration    | Value              |
| ---------------- | ------------------ |
| Instance Type    | `m7i-flex.large`   |
| Subnet           | Private Subnet     |
| Public IP        | ❌ No               |
| OS               | Amazon Linux 2023  |
| Application Port | `80`               |
| Container Port   | `80`               |
| Role             | Application Server |

The application server should not be directly accessible from the Internet.

---

# 🛡️ Security Group Configuration

A secure configuration should use **separate Security Groups** for the Bastion and Application Server.

## Bastion Security Group

### Inbound Rules

| Protocol | Port | Source                | Purpose                |
| -------- | ---: | --------------------- | ---------------------- |
| TCP      |   22 | `<YOUR_PUBLIC_IP>/32` | SSH from administrator |

Example:

```text
SSH
Port: 22
Source: <YOUR_PUBLIC_IP>/32
```

### Outbound Rules

```text
All traffic → 0.0.0.0/0
```

---

# 🔒 Application Server Security Group

### Inbound Rules

| Protocol | Port | Source                     | Purpose                  |
| -------- | ---: | -------------------------- | ------------------------ |
| TCP      |   22 | Bastion Security Group     | SSH from Bastion         |
| TCP      |   80 | Bastion/ALB Security Group | HTTP application traffic |

Recommended production architecture:

```text
Internet
   │
   ▼
Application Load Balancer
   │
   │ HTTP/HTTPS
   ▼
Application Server
```

In that case, port `80` should allow traffic **only from the ALB Security Group**.

### Do NOT use:

```text
SSH : 22
Source: 0.0.0.0/0
```

for the Application Server.

---

# 🔐 SSH Architecture

The recommended access flow is:

```text
Local Machine
      │
      │ SSH
      ▼
Bastion Host
      │
      │ SSH
      ▼
Private Application Server
```

The private key should **not be copied onto the Bastion Server**.

Instead, SSH Agent Forwarding can be used.

---

# 🔑 SSH Agent Forwarding

SSH Agent Forwarding allows the Bastion to authenticate to the private Application Server using the SSH key held by the local machine.

### Local Machine

Start the SSH agent:

```bash
eval "$(ssh-agent -s)"
```

Add your private key:

```bash
ssh-add ~/.ssh/<YOUR_KEY>.pem
```

Check:

```bash
ssh-add -l
```

---

# ⚙️ SSH Configuration

Edit:

```bash
~/.ssh/config
```

Example:

```ssh-config
Host bastion
    HostName <BASTION_PUBLIC_IP>
    User ec2-user
    IdentityFile ~/.ssh/<YOUR_KEY>.pem
    IdentitiesOnly yes
    ForwardAgent yes

Host app
    HostName <APP_PRIVATE_IP>
    User ec2-user
```

Replace:

```text
<BASTION_PUBLIC_IP>
<APP_PRIVATE_IP>
<YOUR_KEY>.pem
```

with your own values.

⚠️ **Never commit these real values to GitHub.**

---

# 🔗 Connecting to the Bastion

From the local machine:

```bash
ssh bastion
```

Once connected:

```bash
ssh ec2-user@<APP_PRIVATE_IP>
```

The connection becomes:

```text
Local Machine
      │
      ▼
Bastion
      │
      ▼
Private Application Server
```

---

# 🐳 Docker Installation

On the Application Server:

```bash
sudo dnf update -y
```

Install Docker:

```bash
sudo dnf install docker -y
```

Start Docker:

```bash
sudo systemctl start docker
```

Enable Docker at boot:

```bash
sudo systemctl enable docker
```

Add the user to the Docker group:

```bash
sudo usermod -aG docker ec2-user
```

Reconnect to the server after running the above command.

Verify:

```bash
docker --version
```

Test:

```bash
docker run hello-world
```

---

# 📁 Application Structure

Example project structure:

```text
Project-2/
│
├── index.html
├── style.css
├── Dockerfile
├── nginx.conf
├── .dockerignore
└── README.md
```

---

# 🐳 Dockerfile

Example:

```dockerfile
FROM nginx:1.27-alpine

# Remove default Nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy website files
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Nginx listens on port 80
EXPOSE 80

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
```

---

# 🌐 Nginx Configuration

Example `nginx.conf`:

```nginx
server {
    listen 80;

    server_name _;

    root /usr/share/nginx/html;

    index index.html;

    gzip on;
    gzip_types text/css text/html application/javascript application/json;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~* \.css$ {
        expires 7d;
        add_header Cache-Control "public";
    }
}
```

---

# 🔨 Build Docker Image

Navigate to the project directory:

```bash
cd Project-2
```

Build the image:

```bash
sudo docker build -t my-app .
```

Verify:

```bash
sudo docker images
```

Expected:

```text
REPOSITORY    TAG       IMAGE ID
my-app        latest    <IMAGE_ID>
```

---

# ▶️ Run the Application

Run the container:

```bash
sudo docker run -d \
    --name my-app \
    -p 80:80 \
    my-app
```

Check the container:

```bash
sudo docker ps
```

Expected:

```text
CONTAINER ID   IMAGE     STATUS          PORTS
xxxxxxxx       my-app    Up ...          0.0.0.0:80->80/tcp
```

---

# 🧪 Application Testing

## Test Nginx

On the Application Server:

```bash
curl -I http://localhost
```

Expected:

```text
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html
```

---

## Test Website Content

```bash
curl http://localhost
```

This should return the HTML content of the website.

---

## Check Docker Container

```bash
sudo docker ps
```

---

## Check Container Logs

```bash
sudo docker logs my-app
```

---

## Check Nginx Configuration

```bash
sudo docker exec my-app nginx -t
```

Expected:

```text
syntax is ok
test is successful
```

---

# 🌐 Local Browser Testing

Because the Application Server is private, its private IP cannot normally be opened directly from your local browser.

For temporary testing, an SSH tunnel can be created through the Bastion.

From your **local machine**:

```bash
ssh -L 8080:<APP_PRIVATE_IP>:80 bastion
```

Keep the SSH session open.

Then open your browser:

```text
http://localhost:8080
```

Traffic flows as:

```text
Browser
   │
   │ localhost:8080
   ▼
Local Machine
   │
   │ SSH Tunnel
   ▼
Bastion
   │
   │ Private Network
   ▼
Application Server :80
   │
   ▼
Docker :80
   │
   ▼
Nginx
   │
   ▼
Website
```

This allows you to test the private application without assigning a public IP to the Application Server.

---

# 🔍 Troubleshooting

## Container is not running

Check:

```bash
sudo docker ps -a
```

Check logs:

```bash
sudo docker logs my-app
```

Start the container:

```bash
sudo docker start my-app
```

---

## Port 80 is not responding

Check:

```bash
sudo ss -lntp | grep ':80'
```

Check Docker:

```bash
sudo docker ps
```

Test locally:

```bash
curl -I http://localhost
```

---

## Nginx configuration error

Run:

```bash
sudo docker exec my-app nginx -t
```

Check logs:

```bash
sudo docker logs my-app
```

---

## Cannot SSH to Application Server

Verify:

```text
Local Machine
      │
      ▼
Bastion :22
      │
      ▼
Application :22
```

Check the Application Security Group.

The inbound SSH rule should allow:

```text
Source = Bastion Security Group
Port   = 22
```

Do not expose:

```text
0.0.0.0/0 → 22
```

---

# 🔐 Security Best Practices

### ✅ Bastion Host

* Keep SSH access restricted to a trusted public IP.
* Use a dedicated Security Group.
* Keep the Bastion lightweight.
* Do not host the application on the Bastion.
* Do not store private keys on the Bastion.

### ✅ Application Server

* Keep it in a private subnet.
* Do not assign a public IP.
* Allow SSH only from the Bastion Security Group.
* Allow HTTP only from the required source.
* Run the application using Docker.
* Keep unnecessary ports closed.

### ✅ SSH

Use:

```text
SSH Agent Forwarding
```

instead of copying private keys to servers.

### ✅ GitHub

Never commit:

```text
*.pem
*.key
.env
terraform.tfvars
credentials
access keys
secret keys
passwords
private IPs
public IPs
AWS account IDs
```

Example `.gitignore`:

```gitignore
# Private keys
*.pem
*.key

# Environment files
.env
.env.*

# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log

# Terraform variable files
*.tfvars

# SSH
.ssh/

# OS files
.DS_Store
Thumbs.db
```

---

# 🧹 Docker Management

List containers:

```bash
sudo docker ps
```

List all containers:

```bash
sudo docker ps -a
```

Stop application:

```bash
sudo docker stop my-app
```

Remove container:

```bash
sudo docker rm my-app
```

Remove image:

```bash
sudo docker rmi my-app
```

View logs:

```bash
sudo docker logs my-app
```

Follow logs:

```bash
sudo docker logs -f my-app
```

---

# 📊 Useful Verification Commands

### EC2

```bash
hostname
ip addr
```

### Docker

```bash
docker --version
sudo systemctl status docker
sudo docker ps
sudo docker images
```

### Network

```bash
ss -lntp
```

### Website

```bash
curl -I http://localhost
```

### Nginx

```bash
sudo docker exec my-app nginx -t
```

---

# 🏢 Production Architecture

For a real production environment, the architecture can be extended to:

```text
                         🌍 Internet
                              │
                              ▼
                     🔐 HTTPS :443
                              │
                              ▼
                  ┌────────────────────┐
                  │   AWS ALB           │
                  │ Application LB      │
                  └─────────┬──────────┘
                            │
                            │ HTTP :80
                            ▼
               ┌──────────────────────────┐
               │ 🔒 Private Subnet        │
               │                          │
               │ 🖥️ Application EC2       │
               │       │                  │
               │       ▼                  │
               │ 🐳 Docker                │
               │       │                  │
               │       ▼                  │
               │ 🌐 Nginx :80             │
               └──────────────────────────┘


Administrator
     │
     │ SSH :22
     ▼
🛡️ Bastion
     │
     │ SSH
     ▼
Private EC2
```

In a production design:

* 🌍 Internet traffic → ALB
* 🔐 HTTPS termination → ALB
* 🔒 Application EC2 → Private Subnet
* 🛡️ Bastion → Administrative access
* 🐳 Docker → Application runtime
* 🌐 Nginx → Web server
* 🔑 SSH → Restricted access
* 🛡️ Security Groups → Network-level access control

For larger environments, AWS Systems Manager Session Manager can also be considered instead of maintaining a traditional Bastion host.

---

# 🧰 Technologies Used

| Technology              | Purpose                |
| ----------------------- | ---------------------- |
| ☁️ AWS EC2              | Compute                |
| 🛡️ Bastion Host        | Secure SSH entry point |
| 🔒 AWS Security Groups  | Network security       |
| 🌐 Nginx                | Web server             |
| 🐳 Docker               | Containerization       |
| 🐧 Amazon Linux 2023    | Operating System       |
| 🔑 SSH                  | Secure administration  |
| 🔐 SSH Agent Forwarding | Key authentication     |
| 📄 HTML                 | Website structure      |
| 🎨 CSS                  | Website styling        |
| 🐙 Git/GitHub           | Version control        |

---

# 🎯 Key DevOps Concepts Demonstrated

This project demonstrates practical understanding of:

* EC2 provisioning
* Public and private subnet architecture
* Bastion / Jump Server
* Security Groups
* SSH
* SSH Agent Forwarding
* Private IP communication
* Docker image creation
* Docker container deployment
* Docker port mapping
* Nginx configuration
* Static website hosting
* Application troubleshooting
* Linux administration
* Network troubleshooting
* Secure infrastructure design

---

# 📸 Project Screenshots

Add your screenshots to a folder:

```text
screenshots/
├── architecture.png
├── ec2-instances.png
├── security-groups.png
├── docker-build.png
├── docker-container.png
├── nginx.png
└── website.png
```

Then reference them in this README:

```markdown
## 🏗️ Architecture

![Architecture](screenshots/architecture.png)
```

```markdown
## ☁️ EC2 Infrastructure

![EC2 Instances](screenshots/ec2-instances.png)
```

```markdown
## 🛡️ Security Groups

![Security Groups](screenshots/security-groups.png)
```

```markdown
## 🐳 Docker Container

![Docker Container](screenshots/docker-container.png)
```

```markdown
## 🌐 Website

![Website](screenshots/website.png)
```

---

# 📂 Recommended Repository Structure

```text
Project-2/
│
├── 📄 index.html
├── 🎨 style.css
├── 🐳 Dockerfile
├── 🌐 nginx.conf
├── 🚫 .dockerignore
├── 🚫 .gitignore
├── 📖 README.md


---

# 🚀 Deployment Summary

```text
1. Create VPC/Subnets
          ↓
2. Create Bastion EC2
          ↓
3. Create Private Application EC2
          ↓
4. Configure Security Groups
          ↓
5. Configure SSH Agent Forwarding
          ↓
6. Connect to Bastion
          ↓
7. Connect to Private Application Server
          ↓
8. Install Docker
          ↓
9. Copy Application Files
          ↓
10. Build Docker Image
          ↓
11. Run Docker Container
          ↓
12. Nginx Serves Website
          ↓
13. Test with curl / SSH Tunnel
```

---

# ✅ Final Result

The final environment provides:

```text
🛡️ Secure Administrative Access
              +
🔒 Private Application Server
              +
🐳 Dockerized Application
              +
🌐 Nginx Web Server
              +
🛡️ Security Group Controls
              +
🔐 SSH Agent Forwarding
              =
🏗️ Practical AWS DevOps Deployment
```

---

## 👨‍💻 Project Purpose

This project was created to practice and demonstrate real-world DevOps concepts involving AWS infrastructure, Linux administration, networking, security, Docker containerization, Nginx, and secure application deployment.

> **Principle:** Keep the application private, restrict administrative access, containerize the workload, and expose only the required services.
