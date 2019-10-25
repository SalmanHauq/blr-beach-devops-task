provider "azurerm" {
  version = "1.34.0"
}

resource "azurerm_resource_group" "test" {
  name = "testResourceGroup1"
  location = "KoreaCentral"

  tags = {
    environment = "Production"
  }
}
resource "azurerm_virtual_network" "test_vnet" {
  name = "testVnet1"
  address_space = ["172.20.0.0/16"]
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.test.name}"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "test_subnet1" {
  name = "testSubnet1"
  resource_group_name = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test_vnet.name}"
  address_prefix = "172.20.10.0/24"
}

resource "azurerm_subnet" "test_subnet2" {
  name = "testSubnet2"
  resource_group_name = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test_vnet.name}"
  address_prefix = "172.20.20.0/24"
}

resource "azurerm_public_ip" "test_publicIp" {
  name = "testPublicIp"
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.test.name}"
  public_ip_address_allocation = "dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_public_ip" "test_publicIp_loadBalancer" {
  name = "testPublicIpLoadBalancer"
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.test.name}"
  public_ip_address_allocation = "static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "test_public_network_interface" {
  name = "testPublicNetworkInterface"
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.test.name}"
  ip_configuration {
    name = "test_public_ip_config"
    subnet_id = "${azurerm_subnet.test_subnet1.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.test_publicIp.id}"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "test_private_network_interface" {
  name = "testPrivateNetworkInterface"
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.test.name}"
  ip_configuration {
    name = "test_private_ip_config"
    subnet_id = "${azurerm_subnet.test_subnet2.id}"
    private_ip_address_allocation = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.test_backend_pool.id}"]
    load_balancer_inbound_nat_rules_ids     = ["${azurerm_lb_nat_rule.test_lb_nat_rule.id}"]
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_machine" "test_public_vm" {
  name = "testPublicVm"
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test_public_network_interface.id}"]
  vm_size = "Standard_B1ms"

  storage_os_disk {
    name = "testPublicOsDisk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  os_profile {
    computer_name = "mypublicvm"
    admin_username = "azureuser"
    custom_data = "${file("./cloud-init.sh")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWk9k1MLaFJiCWouDQWTQ01Ewkc/uSaLpskGS07FUhNkAymiWGrpqtZqNbZvtxgWr1AgopOcQ3rz95xuAB3i8HAppkGs0fDKlRB3mlde+zpg2OYBpXQZeleC/42XaZRkkJPucFhcjnyMStFcMcJ99oc2cUQpjtiPon+I19DWJZqc3XOlR5+RqSd4LCPb4VY8yjhUXDxCpZEUK2DyVQlYRQM/tn8ZeEJjukETi+tDQGWREKEJfZvCF971h/txPlvRd9efxb5XJaZAh2yaV5XVP0WaDJCQagwdOoblsbb2TmYcQQnBU7X0H7WWdsCLUTxaZ8o9m6KBx/yYkJyOr7IE8H salmanhauq@Salmans-MacBook-Pro.local"
    }
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_machine" "test_private_vm" {
  name = "testPrivateVm"
  location = "KoreaCentral"
  resource_group_name = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test_private_network_interface.id}"]
  vm_size = "Standard_B1ms"

  storage_os_disk {
    name = "testPrivateOsDisk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04.0-LTS"
    version = "latest"
  }

  os_profile {
    computer_name = "myprivatevm"
    admin_username = "azureuser"
    custom_data = "${file("./cloud-init-private.sh")}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWk9k1MLaFJiCWouDQWTQ01Ewkc/uSaLpskGS07FUhNkAymiWGrpqtZqNbZvtxgWr1AgopOcQ3rz95xuAB3i8HAppkGs0fDKlRB3mlde+zpg2OYBpXQZeleC/42XaZRkkJPucFhcjnyMStFcMcJ99oc2cUQpjtiPon+I19DWJZqc3XOlR5+RqSd4LCPb4VY8yjhUXDxCpZEUK2DyVQlYRQM/tn8ZeEJjukETi+tDQGWREKEJfZvCF971h/txPlvRd9efxb5XJaZAh2yaV5XVP0WaDJCQagwdOoblsbb2TmYcQQnBU7X0H7WWdsCLUTxaZ8o9m6KBx/yYkJyOr7IE8H salmanhauq@Salmans-MacBook-Pro.local"
    }
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_lb" "test_lb" {
  resource_group_name = "${azurerm_resource_group.test.name}"
  name                = "testLb"
  location            = "KoreaCentral"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.test_publicIp_loadBalancer.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "test_backend_pool" {
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id     = "${azurerm_lb.test_lb.id}"
  name                = "BackendPool1"
}

resource "azurerm_lb_nat_rule" "test_lb_nat_rule" {
  resource_group_name            = "${azurerm_resource_group.test.name}"
  loadbalancer_id                = "${azurerm_lb.test_lb.id}"
  name                           = "testLbNatRule"
  protocol                       = "tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
}

resource "azurerm_lb_rule" "test_lb_rule" {
  resource_group_name            = "${azurerm_resource_group.test.name}"
  loadbalancer_id                = "${azurerm_lb.test_lb.id}"
  name                           = "testLbRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.test_backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.test_lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.test_lb_probe"]
}

resource "azurerm_lb_probe" "test_lb_probe" {
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id     = "${azurerm_lb.test_lb.id}"
  name                = "testTcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}