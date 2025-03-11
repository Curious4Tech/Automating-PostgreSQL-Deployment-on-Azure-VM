resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "postgresql-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B2s"  # Adjust size based on your needs

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"  # Ubuntu 22.04 LTS
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name  = "postgresqlvm"
  admin_username = var.vm_username
  admin_password = var.vm_password
  
  disable_password_authentication = false

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
}