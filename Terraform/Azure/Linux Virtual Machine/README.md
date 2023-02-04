# Linux Virtual Machine

A simple terraform template to create a virtual machine in Azure.

## Change before using

```bash
backend "azurerm" in `main.tf` # Can be removed and have the statefile locally.

"azurerm_network_security_rule" in `main.tf` # Configure network security rules you need.

location in main.tf # Configure your location. Default to norwayeast.

Variables in `terraform.tfvars`. # Add tags
```

You also need an ssh key.
