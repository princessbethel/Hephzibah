variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
}

variable "ssh_key_id" {
  description = "DigitalOcean SSH key ID"
  type        = string
}

variable "ssh_private_key" {
  description = "The path to the SSH private key"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key content"
  type        = string
}