#aqui definimos proveedor con llaves generadas de aws
provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS__SECRET_ACCESS_KEY
  region     = "us-east-1"
}
resource "aws_instance" "Docker-Swarm" {
  instance_type = "t2.micro"
  count         = 4
  ami           = "ami-08d4ac5b634553e16"
  tags = {
    "Name" = "Node-${count.index}"
  }
  key_name               = "MRSI"
  user_data              = filebase64("${path.module}/scripts/docker.sh")
  vpc_security_group_ids = [aws_security_group.DockerWebSG.id]

}
resource "aws_security_group" "DockerWebSG" {
  name = "sg_reglas_firewall_docker_swarm"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {                     #Reglas de firewall de entrada
    cidr_blocks = ["0.0.0.0/0"] #Se aplicará a todas las direcciones
    description = "SG HTTP Visualizer"     #Descripción
    from_port   = 8080            #Del puerto
    to_port     = 8080            #Al puerto
    protocol    = "tcp"         #Protocolo
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["172.31.28.80/32", "172.31.91.120/32", "172.31.27.43/32","172.31.17.250/32"] #AQUI CAMBIAR LAS IP DE CADA INSTANCIA
    description = "SG Docker Swarm"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG ALL Trafic Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

output "public_ip" {
  value = join(",", aws_instance.Docker-Swarm.*.public_ip)
}

