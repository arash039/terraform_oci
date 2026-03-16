provider "oci" {
  region = var.oci_region
}

resource "oci_core_vcn" "main" {
  cidr_block   = "10.0.0.0/16"
  display_name = "OracleTestVCN"
  dns_label    = "oracletestvcn"
  compartment_id = var.compartment_id 
}

resource "oci_core_subnet" "main" {
  vcn_id             = oci_core_vcn.main.id
  cidr_block         = "10.0.1.0/24"
  display_name       = "MainSubnet"
  dns_label          = "mainsubnet"
  prohibit_public_ip_on_vnic = false
  route_table_id     = oci_core_route_table.main.id
  compartment_id     = var.compartment_id 
}

resource "oci_core_internet_gateway" "main" {
  vcn_id       = oci_core_vcn.main.id
  display_name = "MainInternetGateway"
  enabled      = true
  compartment_id = var.compartment_id 
}

resource "oci_core_route_table" "main" {
  vcn_id = oci_core_vcn.main.id
  compartment_id = var.compartment_id 

  route_rules {
    destination        = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.main.id
  }

  display_name = "MainRouteTable"
}

resource "oci_core_security_list" "wordpress_sg" {
  vcn_id = oci_core_vcn.main.id
  compartment_id = var.compartment_id 

  ingress_security_rules {
    protocol = "6" 
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6" 
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }

  display_name = "WordPressSecurityList"
}

resource "oci_core_instance" "wordpress" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id = oci_core_subnet.main.id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }

  source_details {
    source_type = "image"
    source_id   = "exampleimage"
  }

  display_name = "WordPressServer"
}

data "oci_core_images" "oracle_linux" {
  compartment_id = var.compartment_id

  filter {
    name   = "operating_system"
    values = [var.operating_system]
  }

  filter {
    name   = "operating_system_version"
    values = [var.operating_system_version]
  }

  filter {
    name   = "shape"
    values = [var.instance_shape]
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "null_resource" "provision_wordpress" {
  provisioner "file" {
    source      = "provision_wordpress.sh"
    destination = "/home/ubuntu/provision_wordpress.sh"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" 
    private_key = file("~/.ssh/id_rsa_terraform")
    host        = oci_core_instance.wordpress.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/provision_wordpress.sh",
      "/home/ubuntu/provision_wordpress.sh > /home/ubuntu/provision_log.txt 2>&1"
    ]
  }
}

