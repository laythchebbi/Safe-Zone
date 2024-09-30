
# Terraform: Secure by Design

## Overview

Welcome to the **Terraform: Secure by Design** repository! This project provides Terraform templates that help you build and maintain **Microsoft Secure by Design** infrastructures in **Azure**. These templates are designed to promote automated, secure cloud deployments, ensuring your infrastructure adheres to **Azure best practices** and security principles from day one.

## Key Features

- **Automated Deployments**: Automate the creation and configuration of secure Azure resources and Secure Architecutres using Terraform.
- **Security Best Practices**: Each template follows **Microsoft’s Secure by Design** framework, which emphasizes secure architecture, network security, identity management, and resource monitoring.
- **Modular Structure**: The templates are modular, enabling you to customize and extend them for your specific security needs.
- **Infrastructure as Code (IaC)**: Manage your Azure infrastructure with version-controlled, repeatable deployments using Terraform's declarative language.
- **Compliance Ready**: Built with compliance in mind, ensuring alignment with key security standards such as CIS, NIST, and Azure Security Benchmarks.

## Getting Started

### Prerequisites

- **Terraform**: Ensure you have [Terraform](https://www.terraform.io/) installed on your local machine.
- **Azure CLI**: Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) to interact with your Azure account.
- **Azure Subscription**: You need an active **Azure subscription** to deploy these resources.

### Cloning the Repository

\`\`\`bash
git clone https://github.com/laythchebbi/Safe-Zone.git
cd terraform-secure-by-design
\`\`\`

### Deploying the Templates

1. **Authentication**: Authenticate to your Azure account using Azure CLI.
   
   \`\`\`bash
   az login
   \`\`\`

2. **Initialize Terraform**: Run the following command to initialize the working directory containing the Terraform configuration files.

   \`\`\`bash
   terraform init
   \`\`\`

3. **Plan and Apply**: Run the following commands to review and deploy the infrastructure.

   \`\`\`bash
   terraform plan
   terraform apply
   \`\`\`

4. **Confirmation**: Confirm the changes by typing `yes` when prompted.

## Template Structure

- **Networking**: Secure VNet setup with subnets, NSGs, and Azure Firewall.
- **Identity**: Configure secure identity access management with Azure Active Directory, RBAC, and Managed Identities.
- **Monitoring**: Set up monitoring and logging for all critical resources using Azure Monitor and Log Analytics.
- **Security Controls**: Includes templates for Azure Security Center, Defender for Cloud, and Key Vaults with strict access policies.
  
## Customization

Feel free to modify the variables in the `variables.tf` file to suit your environment. You can pass custom values during deployment by using the `-var` option:

\`\`\`bash
terraform apply -var="resource_group_name=myResourceGroup"
\`\`\`

## Contributing

We welcome contributions to improve and extend these templates! Please submit a pull request or create an issue if you have any suggestions.

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.
