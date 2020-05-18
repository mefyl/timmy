provider "digitalocean" {
  token = "d062425fb18e3fb59fc12a78f474b1ae1c3c8b21df1c91f66982cc928fe0b0ff"
}

variable "name" {
  type = string
}

variable "region" {
  type = string
  default = "fra1"
}

variable "replicas" {
  type = number
  default = 3
}

resource "digitalocean_vpc" "vpc" {
  name     = var.name
  region   = var.region
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "droplets" {
  image  = "ubuntu-18-04-x64"
  count  = var.replicas
  name   = "${var.name}-${count.index}"
  monitoring = true
  region = var.region
  size   = "s-1vcpu-3gb"
  ssh_keys   = [27014658] # mefyl
  vpc_uuid = digitalocean_vpc.vpc.id
  user_data  = <<EOF
#cloud-config
apt:
  sources:
    docker:
      source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable"
      keyid: 0EBFCD88
packages:
  - apt-transport-https
  - ca-certificates
  - docker-ce
  - docker-ce-cli
  - nginx
  - nginx-extra
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq1pXuFI8l8MopHufZ4S3fe+WoR5wgeaPtZhw9IFuHZ+3F7V7fCzy76gKp5EPz5sk2Dowd90d+TuEUjUUkI0fRLJipRPjo2reFsuOAZ244ee/NLtG601vQUS/sV8ow2QZEAoNAiNZQGr4jEqvmjIB+rwOmx9eUgs887KjUYlX+wH5984EAr/qd62VddYXga8o4T2QX4GlYik/s/yKm0dlCQgZXQPYM5Wogv6KluGdLFKBaNc2HYkGEArZE51sATRcDOSQcycg2sGuwfL/LfClsCkx2LSYjJh9qkiBNUsAg+LeRt/9Hv3S32tcMszCph3nSX5u+1yz8VURHjVGh9ptAw== mefyl
EOF
}


# DO LE certificates does not work with subdomains
# resource "digitalocean_domain" "domain" {
#   name       = "staging.routine.co"
# }

resource "digitalocean_record" "records" {
  count      = var.replicas
  domain     = "routine.co"
  type       = "A"
  name       = "${count.index}.api.${var.name}"
  value      = digitalocean_droplet.droplets[count.index].ipv4_address
}

resource "digitalocean_certificate" "api" {
  name    = "api-${var.name}-certificate"
  type    = "lets_encrypt"
  domains = ["api.${var.name}.routine.co"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_loadbalancer" "api" {
  name   = var.name
  region = var.region
  vpc_uuid = digitalocean_vpc.vpc.id
  redirect_http_to_https = true

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"
    certificate_id = digitalocean_certificate.api.id

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    port     = 8080
    path     = "/"
    protocol = "http"
  }

  droplet_ids = digitalocean_droplet.droplets[*].id
}

resource "digitalocean_record" "api" {
  domain     = "routine.co"
  type       = "A"
  name       = "api.${var.name}"
  value      = digitalocean_loadbalancer.api.ip
}

resource "digitalocean_project" "project" {
  name        = title(var.name)
  description = "Continuous delivery"
  purpose     = "Web Application"
  resources   = concat(
    digitalocean_droplet.droplets[*].urn,
    [
      digitalocean_loadbalancer.api.urn
      #, digitalocean_vpc.vpc.urn
    ])
}
