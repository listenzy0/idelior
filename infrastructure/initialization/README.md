> **Note**: The document is currently drafted temporarily and is not yet complete.

# Initialization

This document outlines the initial setup steps required to establish the foundational infrastructure for the **Idelior** e-commerce platform. These steps are essential to prepare the environment for further configuration and deployment.

## Architecture

### Diagram

![Initialization](images/diagram.png)

### Components

- **Domain (`idelior.com`, in GoDaddy):** Used for basic domain settings and linking with Google Workspace, Google Cloud, and AWS.
- **Domain (`idelior.com`, in Google Workspace):** A domain linked with Google Workspace, enabling the use of `@idelior.com` email addresses.
- **Account (`root@idelior.com`, at Domain):** The primary administrator account for managing all components.
- **Organization (`idelior.com`, in Google Cloud):** The top-level container in Google Cloud that allows centralized management of resources.
- **Project (`workspace`, at Organization):** An independent workspace in Google Cloud for logically separating and managing resources, where the IaC credentials for Google Workspace are stored.
- **Service Account (`workspace`, on Project):** A programmatic access account for handling IaC operations for Google Workspace.
- **Key (`for IaC`, on Service Account):** An authentication key linked to the service account for managing IaC processes.
- **Organization (`Idelior`, in Amazon Web Services):** The top-level container in Amazon Web Services (AWS) for centralized management of multiple accounts, integrating policies and resources.
- **Account root User (`root@idelior.com`, at Organization):** The primary root account for the AWS organization, created using the Google Workspace administrator account.
- **IAM User (`root`, on Account root User):** A programmatic access-only account for handling IaC operations in AWS.
- **Access Key (`for IaC`, on IAM User):** An authentication key linked to the IAM user for managing IaC processes.



## Steps

### 1. Domain Purchase

**Domain Name Selection:**
The domain `idelior.com` was selected to represent the project. This domain was chosen for its short, memorable nature and its ability to clearly convey the brand identity.

**Domain Purchase:**
The domain was purchased through GoDaddy for two primary reasons:
1. **Reliability:** GoDaddy is a trusted platform with a long history of providing domain registration services.
2. **Cost:** Thanks to a promotion offered by GoDaddy, `idelior.com` was available at the most affordable price.

**Challenges:**
Initially, the plan was to manage the domain via Terraform using GoDaddy's API. However, GoDaddy's API is only available to Enterprise plans or accounts managing more than 50 domains, which required a change in our original approach.




### 1. AWS Account Setup

- **Create an AWS Account:** Ensure you have an active AWS account. If not, [create one here](https://aws.amazon.com/).
- **Configure IAM Users and Roles:** 
  - Create IAM users with appropriate permissions.
  - Set up roles for administration and deployment purposes.
- **Billing Alerts:** Set up billing alerts to monitor and control costs.

### 2. VPC Configuration

- **Create a Virtual Private Cloud (VPC):**
  - Define the IP range (CIDR block) for your VPC (e.g., `10.0.0.0/16`).
- **Subnets:**
  - Create public and private subnets within your VPC.
  - Assign appropriate IP ranges for each subnet.
- **Internet Gateway and NAT Gateway:**
  - Attach an Internet Gateway to the VPC for public subnet access.
  - Set up a NAT Gateway for instances in the private subnet to access the internet securely.

### 3. Security Groups and Network ACLs

- **Security Groups:**
  - Create security groups to control inbound and outbound traffic for your resources.
  - Example: Allow HTTP/HTTPS traffic for web servers, allow SSH access from specific IPs.
- **Network ACLs:**
  - Set up network ACLs to add an additional layer of security at the subnet level.

### 4. Initial EC2 Instance Launch

- **Choose an AMI:** Select a suitable Amazon Machine Image (AMI) for your EC2 instances.
- **Instance Type:** Start with a general-purpose instance type (e.g., `t2.micro` for testing).
- **Key Pair:** Generate or use an existing key pair for SSH access to the instance.
- **Assign Security Groups:** Attach the previously created security group to the instance.

### 5. S3 Bucket Setup (Optional)

- **Create S3 Buckets:** 
  - Set up S3 buckets for storing static assets,

