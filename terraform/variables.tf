variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
  default     = "us-east-1"
}
variable "project_name" {
  description = "Prefix used in resource names and tags"
  type        = string
  default     = "k3s-ollama"
}

variable "vpc_cidr" {
  description = "IP range for the whole VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IP range for the public subnet (master)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "IP range for the private subnet (workers)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = string
  default     = "us-east-1a"
}

variable "my_ip" {
  description = "Your public IP in CIDR form (x.x.x.x/32) — allowed to reach SSH, K3S API and web"
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key that will be installed on the servers"
  type        = string
  default     = "~/.ssh/k3s-ollama.pub"
}

variable "master_instance_type" {
  description = "EC2 instance type for the K3S master"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "EC2 instance type for the K3S workers"
  type        = string
  default     = "t3.medium"
}

variable "worker_count" {
  description = "How many worker nodes to create"
  type        = number
  default     = 3
}