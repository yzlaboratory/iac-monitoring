terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_volume" "grafana-storage" {
    name = "grafana-storage"
}

resource "docker_network" "grafana-oss-network" {
    name = "grafana-oss-network"
}

resource "docker_image" "grafana" {
    name         = "grafana/grafana-oss:latest"
    keep_locally = false
}

resource "docker_image" "loki" {
    name         = "grafana/loki:latest"
    keep_locally = false
}

resource "docker_image" "mimir" {
    name         = "grafana/mimir:latest"
    keep_locally = false
}

resource "docker_image" "tempo" {
    name = "grafana/tempo:latest"
    keep_locally = false
}

resource "docker_container" "grafana" {
    image = docker_image.grafana.image_id
    name  = "grafana"
    ports {
        internal = 3000
        external = 3000
    }
    volumes {
        volume_name = "grafana-storage"
        container_path = "/var/lib/grafana" 
    }
}

resource "docker_container" "loki" {
    image = docker_image.loki.image_id
    name  = "loki"
    ports {
        internal = 3100
        external = 3100
    }
    command = ["-config.file=./configs/loki/local-config.yaml"]
    networks_advanced {
        name = "grafana-oss-network"
    }
     //configure proper storage in config file and mount as volume
}

resource "docker_container" "mimir" {
    image = docker_image.mimir.image_id
    name  = "mimir"
    ports {
        internal = 9009
        external = 9009
    }
    command = ["-config.file=./configs/mimir/config.yaml"]
    networks_advanced {
        name = "grafana-oss-network"
    }
    //configure proper storage in config file and mount as volume
}


//add tempo