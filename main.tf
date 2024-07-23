# Resource group student-rg
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name = var.resource_group_name
}

# Virtual Network student-vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "student-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# SubNet student-subnet
resource "azurerm_subnet" "subnet" {
  name                 = "student-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

# Network Security Group student-nsg
resource "azurerm_network_security_group" "nsg" {
  name                = "student-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP student-pip
resource "azurerm_public_ip" "publicIP" {
  name                = "student-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Network Interface student-nic
resource "azurerm_network_interface" "nic" {
  name                = "student-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIP.id
  }
}

# VM student-vm
resource "azurerm_linux_virtual_machine" "studentVm" {
  name                  = "student-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"
  os_disk {
    name                 = "student-vm-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  computer_name                   = "studentvm"
  admin_username                  = var.vm_username
  admin_password                  = var.vm_password
  disable_password_authentication = false
}

# Generate Inventory
resource "local_file" "hosts_cfg" {
  content = templatefile("inventory.tpl",
    {
      publicIP = azurerm_linux_virtual_machine.studentVm.public_ip_address,
      user     = var.vm_username,
      password = var.vm_password
    }
  )
  filename = "./ansible/inventory.ini"
}