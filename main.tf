resource "azurerm_resource_group" "example" {
  name     = "MyTerraformRG"
  location = "Central US"
}

resource "azurerm_virtual_machine" "main" {
  name                  = "MyTerraformVM"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_D2as_v5"

  storage_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_extension" "example" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  # protected_settings = <<PROT
  #   {
  #       "script": "${base64encode(file(var.filetemp))}"
  #   }
  #   PROT
    settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile(var.filetemp, {
          //vmname="${azurerm_virtual_machine.test.name}"
          hostname=azurerm_mysql_server.example.fqdn
          db_name=azurerm_mysql_database.example.name
          db_user=azurerm_mysql_server.example.administrator_login
          db_password=azurerm_mysql_server.example.administrator_login_password
        }))}"
    }
SETTINGS
  tags = {
    environment = "Production"
  }
}

resource "azurerm_mysql_server" "example" {
  name                = "example-mysqlserver7778"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"
}

resource "azurerm_mysql_database" "example" {
  name                = "exampledb"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_server.example.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


resource "azurerm_mysql_firewall_rule" "example" {
  name                = "office"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mysql_server.example.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"

  output "Wordpress_DNS" {
  value = azurerm_mysql_server.fqdn
}
}