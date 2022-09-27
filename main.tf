#aqui definimos proveedor con llaves generadas de aws
provider "aws" {
  access_key = var.AWS_ACCESS_KEY 
  secret_key =var.AWS__SECRET_ACCESS_KEY 
  region     = "us-east-1"
}
resource "aws_instance" "Reverse-Proxy" {
  instance_type          = "t2.micro"
  ami                    = "ami-08d4ac5b634553e16"
  key_name               = "MRSI"
  user_data              = filebase64("${path.module}/scripts/docker.sh")
  vpc_security_group_ids = [aws_security_group.WebSG.id]

}
resource "aws_security_group" "WebSG" {
  name = "sg_reglas_firewall"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG HTTPS"
    from_port   = 443
    to_port     = 443
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
  value = join(",", aws_instance.Reverse-Proxy.*.public_ip)
}

