provider "azurerm" {
  features {}
}
locals {
  count_lnx = substr(var.os,0,7)!="windows" ? var.machines_count : 0
  count_win = substr(var.os,0,7)=="windows" ? var.machines_count : 0
}
resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_public_ip" "public-ip" {
  count = var.machines_count
  name = "${var.name}${count.index}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.name}${count.index}"
}

resource "azurerm_network_interface" "nic" {
  count               = var.machines_count
  name                = "${var.name}${count.index}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "main"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "lin-vm" {
  count               = local.count_lnx
  name                = "${var.name}${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = lookup(var.map_instance_type, var.instance_type)
  admin_username      = "adminuser"
  
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/../${var.pub_key}")
  }

  custom_data         = base64encode(templatefile("${path.module}/templates/init-lnx.tftpl",{
    primary_ip        = var.primary_ip,
    primary_name      = var.primary_name
    agent_name        = "${var.name}${count.index}",
    dns_domain        = "${var.location}.${var.domain}",
    role              = var.role
    challengepassword = var.challengepassword
    }))
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = lookup(var.os_map_publisher, var.os)
    offer     = lookup(var.os_map_offer, var.os)
    sku       = lookup(var.os_map_sku, var.os)
    version   = "latest"
  }
}

