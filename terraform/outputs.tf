output "master_public_ip" {
  description = "Public IP of the K3S master (SSH, kubectl, ingress)"
  value       = aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Private IP of the K3S master"
  value       = aws_instance.master.private_ip
}

output "worker_private_ips" {
  description = "Private IPs of the K3S workers"
  value       = aws_instance.worker[*].private_ip
}