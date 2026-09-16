resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory.tmpl", {
    master_public_ip   = aws_instance.master.public_ip
    worker_private_ips = aws_instance.worker[*].private_ip
  })
  filename = "${path.module}/../ansible/inventory.ini"
}