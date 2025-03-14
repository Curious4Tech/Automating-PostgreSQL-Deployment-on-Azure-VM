# Automating PostgreSQL Deployment on Azure: A Terraform Journey

  ![image](https://github.com/user-attachments/assets/6754bb9d-4d50-4989-9af8-26f949b6d90c)


## Introduction

As organizations continue to migrate to the cloud, automating infrastructure deployment becomes crucial. Today, I'll share my experience creating a production-ready PostgreSQL database environment on Azure using Infrastructure as Code (IaC) with Terraform. This solution combines the power of Azure's cloud infrastructure with the flexibility of self-managed PostgreSQL.

## The Challenge

Setting up a database environment traditionally involves multiple manual steps:
- Creating virtual networks and security groups
- Deploying and configuring a virtual machine
- Installing and securing PostgreSQL
- Configuring network access and security rules

Manually performing these steps is time-consuming and prone to human error. Additionally, recreating the same environment for different stages (development, staging, production) becomes a challenge.

## The Solution: Infrastructure as Code

I chose Terraform as the IaC tool for this project because of its:
- Declarative syntax
- Strong Azure integration
- Version control friendly approach
- Excellent documentation and community support

## Project Components

The infrastructure consists of several key components:

1. **Networking Layer**
   - Virtual Network with custom subnet
   - Network Security Group with specific rules for SSH and PostgreSQL
   - Public IP for remote access

2. **Compute Layer**
   - Ubuntu 20.04 LTS Virtual Machine
   - Password-based authentication
   - Automated PostgreSQL installation and configuration

3. **Security Layer**
   - Configurable network security rules
   - Secure password policies
   - PostgreSQL access control

## The Code Structure

I organized the Terraform configuration into logical modules:

```hcl
project/
├── main.tf        # Core infrastructure
├── network.tf     # Network configuration
├── vm.tf          # Virtual machine setup
├── variables.tf   # Variable definitions
└── outputs.tf     # Output values
```

## Key Implementation Details

### Security First Approach

The Network Security Group configuration demonstrates our security-first mindset:

```hcl
security_rule {
    name                       = "PostgreSQL"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"   # In production, restrict this to your IP
    destination_address_prefix = "*"
}
```

While this example shows open access, in production, you should restrict the `source_address_prefix` to specific IP ranges.

### Automated PostgreSQL Setup

The VM configuration includes a custom data script that automatically:
- Updates system packages
- Installs PostgreSQL
- Configures remote access
- Sets up security parameters

```bash
custom_data = base64encode(<<-EOF
              #!/bin/bash
              # Update package list and upgrade system
              sudo apt-get update
              sudo apt-get upgrade -y

              # Install PostgreSQL (this will install the latest version from Ubuntu repositories)
              sudo apt-get install -y postgresql postgresql-contrib

              # Get installed PostgreSQL version
              PG_VERSION=$(ls /etc/postgresql/)

              # Configure PostgreSQL to accept connections from any address
              sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/$PG_VERSION/main/postgresql.conf
              
              # Add entry to allow remote connections in pg_hba.conf
              echo "host    all             all             0.0.0.0/0               scram-sha-256" | sudo tee -a /etc/postgresql/$PG_VERSION/main/pg_hba.conf

              # Restart PostgreSQL
              sudo systemctl restart postgresql
              EOF
)
```

## Best Practices and Recommendations

1. **Password Management**
   - Store sensitive data in Azure Key Vault
   - Use strong password policies
   - Regularly rotate credentials

2. **Network Security**
   - Restrict access to specific IP ranges
   - Use private subnets where possible
   - Implement proper network segmentation

3. **Monitoring and Maintenance**
   - Set up Azure Monitor
   - Configure regular backups
   - Plan for updates and patches

## Deployment Process

Deploying the infrastructure is straightforward:

```bash
# Clone the repository
git clone https://github.com/Curious4Tech/postgresql-deployment-automated.git

# Navigate to the project directory
cd postgresql-deployment-automated/terraform_files

#Deploy to azure portal
az login
terraform init
terraform validate
terraform plan
terraform apply
```

## Future Improvements

Future iterations of this project could include:
1. High Availability configuration
2. Automated backup solutions
3. Monitoring and alerting setup
4. Integration with Azure Key Vault
5. Disaster recovery planning

## Conclusion

This project demonstrates how Infrastructure as Code can simplify and standardize database deployment while maintaining security and best practices. The combination of Azure, Terraform, and PostgreSQL provides a robust foundation for any application requiring a reliable database backend.
