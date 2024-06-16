provider "digitalocean" {
  token = var.digitalocean_token
}

resource "digitalocean_droplet" "example" {
  image  = "ubuntu-20-04-x64"
  name   = "example-droplet"
  region = var.region
  size   = "s-1vcpu-1gb"

  tags = ["web"]
}
