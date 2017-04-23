variable "do_token" {
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "obenes_key" {
  name = "obenes_key"
  public_key = "${file("/Users/jamesony/.ssh/digital_ocean_rsa.pub")}"
}

resource "digitalocean_droplet" "ci" {
  image = "centos-7-x64"
  name = "ci"
  region = "nyc2"
  size = "1gb"
  ssh_keys = [
    "${digitalocean_ssh_key.obenes_key.fingerprint}"]

  provisioner "remote-exec" {
    inline = [
      "yum update -y",
      "yum install docker -y",
      "systemctl start docker",
      "systemctl status docker",
      "systemctl enable docker",
      "docker run -itd -p80:8153 -p8154:8154 --name gocd-server gocd/gocd-server:v17.3.0",
      "sleep 1m",
      "docker run -itd --name gocd-agent -e GO_SERVER_URL=https://$(docker inspect --format='{{(index (index .NetworkSettings.IPAddress))}}' gocd-server):$(docker inspect --format='{{(index (index .NetworkSettings.Ports \"8154/tcp\") 0).HostPort}}' gocd-server)/go gocd/gocd-agent-centos-7:v17.3.0"
    ]
    connection {
      user = "root"
      type = "ssh"
    }
  }
}

resource "digitalocean_droplet" "website" {
  image = "centos-7-x64"
  name = "website"
  region = "nyc2"
  size = "1gb"
  ssh_keys = [
    "${digitalocean_ssh_key.obenes_key.fingerprint}"]

  provisioner "remote-exec" {
    inline = [
      "yum update -y",
      "yum install java-1.8.0-openjdk-devel -y"
    ]

    connection {
      user = "root"
      type = "ssh"
    }
  }
}

resource "digitalocean_domain" "default" {
  name = "www.the-obenes.com"
  ip_address = "${digitalocean_droplet.website.ipv4_address}"
}

output "ci_ip_address" {
  value = "${digitalocean_droplet.ci.ipv4_address}"
}

output "website_ip_address" {
  value = "${digitalocean_droplet.website.ipv4_address}"
}