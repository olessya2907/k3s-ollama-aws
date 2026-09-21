resource "aws_security_group" "k3s_nodes" {
  name        = "${var.project_name}-nodes-sg"
  description = "Security group for K3S master and worker nodes"
  vpc_id      = aws_vpc.main.id

  # All traffic between nodes in the same security group (inside the cluster)
  ingress {
    description = "Full traffic between cluster nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # SSH from your machine
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Kubernetes API from your machine (for kubectl)
  ingress {
    description = "K3S API from my IP"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # HTTP to the ingress from your machine
  ingress {
    description = "HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # HTTPS to the ingress from your machine
  ingress {
    description = "HTTPS from my IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # All outbound traffic allowed
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-nodes-sg"
  }
}