variable "digitalocean_token" {
  description = "The DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The DigitalOcean region to deploy in"
  type        = string
  default     = "nyc3"
}
