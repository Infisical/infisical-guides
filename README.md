# Infisical Guides

Examples and guides for Infisical secret management — from Terraform boilerplate to hands-on Kubernetes demos.

## Repository Structure

```
infisical-guides/
├── terraform-examples/         # Production-ready Terraform boilerplate
│   ├── project-bootstrap/     # Complete project setup
│   ├── static-secrets/        # Traditional secret management
│   ├── dynamic-secrets/       # Temporary credential generation
│   ├── secret-rotation/       # Enterprise credential rotation
│   └── secret-syncing/        # External store synchronization
├── kubernetes-examples/        # Hands-on Kubernetes demos
│   └── ESO-With-Infisical/    # External Secrets Operator with Infisical
└── README.md                  # This file
```

## Quick Start

Get started with Infisical in 15 minutes:

```bash
# 1. Clone the repository
git clone https://github.com/Infisical/infisical-guides.git
cd infisical-guides

# 2. Start with project bootstrap
cd terraform-examples/project-bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials
terraform init && terraform apply

# 3. Add static secrets
cd ../static-secrets
# Follow the README for configuration
```

## Terraform Examples

Production-ready Terraform boilerplate for common Infisical use cases:

| Example | Description | Complexity |
|---------|-------------|------------|
| [project-bootstrap](terraform-examples/project-bootstrap/) | Complete project setup with environments and folders | Simple |
| [static-secrets](terraform-examples/static-secrets/) | Traditional secret management (API keys, passwords) | Simple |
| [dynamic-secrets](terraform-examples/dynamic-secrets/) | Temporary database credentials | Advanced |
| [secret-rotation](terraform-examples/secret-rotation/) | Automated credential lifecycle | Enterprise |
| [secret-syncing](terraform-examples/secret-syncing/) | Sync to AWS, GitHub, and other services | Medium |

## Kubernetes Examples

Hands-on demos showing Infisical integrations in Kubernetes environments:

| Example | Description |
|---------|-------------|
| [ESO-With-Infisical](kubernetes-examples/ESO-With-Infisical/) | Sync secrets from Infisical into Kubernetes using External Secrets Operator with Kubernetes Auth |

## For Most Teams

1. Start with `project-bootstrap` to set up your Infisical project
2. Use `static-secrets` for managing API keys and passwords
3. Add `secret-syncing` when you need to distribute secrets to external services
4. Consider advanced features (dynamic secrets, rotation) only for specific enterprise requirements

## Prerequisites

- Terraform >= 1.10.0 (required for ephemeral resources)
- Infisical account with machine identity
- Target services configured (for advanced features)

## Resources

- [Infisical Documentation](https://infisical.com/docs)
- [Terraform Provider Docs](https://registry.terraform.io/providers/Infisical/infisical/latest/docs)
- [Infisical Community](https://infisical.com/slack)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This repository is licensed under the MIT License. See the LICENSE file for details. 
