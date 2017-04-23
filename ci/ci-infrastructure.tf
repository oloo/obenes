variable "do_token" {
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "ci" {
  image = "centos-7-x64"
  name = "ci"
  region = "nyc2"
  size = "1gb"
}

resource "digitalocean_droplet" "website" {
  image = "centos-7-x64"
  name = "website"
  region = "nyc2"
  size = "1gb"
}


resource "digitalocean_domain" "default" {
  name = "www.the-obenes.com"
  ip_address = "${digitalocean_droplet.website.ipv4_address}"
}