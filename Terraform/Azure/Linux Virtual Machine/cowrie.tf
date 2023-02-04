resource "azurerm_public_ip" "fresh_ip" {
  name                = "fresh_ip-linux"
  resource_group_name = azurerm_resource_group.fresh_rg.name
  location            = azurerm_resource_group.fresh_rg.location
  allocation_method   = "Dynamic"

  tags = var.tags
}

resource "azurerm_network_interface" "fresh-ni-linux" {
  name                = "fresh-ni-linux"
  location            = azurerm_resource_group.fresh_rg.location
  resource_group_name = azurerm_resource_group.fresh_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.fresh_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.fresh_ip.id
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "fresh-vm" {
  name                = "fresh-vm"
  resource_group_name = azurerm_resource_group.fresh_rg.name
  location            = azurerm_resource_group.fresh_rg.location
  size                = "Standard_B1s"
  #size           = "Standard_B2s"
  admin_username = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.fresh-ni-linux.id,
  ]

  #custom_data = filebase64("fresh.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/<your pub key>")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku   = "22_04-lts"
    version = "latest"
  }
  tags = var.tags
}

data "azurerm_public_ip" "fresh-public-ip" {
  name                = azurerm_public_ip.fresh_ip.name
  resource_group_name = azurerm_resource_group.fresh_rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.fresh-vm.name} : ${data.azurerm_public_ip.fresh-public-ip.ip_address}"
  depends_on = [
    azurerm_linux_virtual_machine.fresh-vm
  ]
}