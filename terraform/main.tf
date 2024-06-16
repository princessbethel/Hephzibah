terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_droplet" "existing" {
  name = "app-server"
}

resource "digitalocean_droplet" "app_server" {
  count = data.digitalocean_droplet.existing.id == "" ? 1 : 0
  image    = "ubuntu-20-04-x64"
  name     = "app-server"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_key_id]

  provisioner "remote-exec" {
    inline = [
      "apt-get update && apt-get upgrade -y",
      "apt-get install -y sshpass",
      "useradd -m -s /bin/bash deployer",
      "echo 'deployer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers",
      "mkdir -p /home/deployer/.ssh",
      "echo '${var.ssh_public_key}' > /home/deployer/.ssh/authorized_keys",
      "chown -R deployer:deployer /home/deployer/.ssh",
      "chmod 700 /home/deployer/.ssh",
      "chmod 600 /home/deployer/.ssh/authorized_keys"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key)
      host        = self.ipv4_address
    }
  }

  provisioner "local-exec" {
    command = <<EOF
      ssh-keyscan -H ${self.ipv4_address} >> ~/.ssh/known_hosts
    EOF
  }
}

output "app_server_ip" {
  value = coalesce(
    data.digitalocean_droplet.existing.ipv4_address, 
    try(digitalocean_droplet.app_server[0].ipv4_address, null)
  )
}
