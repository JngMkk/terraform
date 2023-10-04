output "instance_id_addr" {
  value = "http://${aws_instance.server.private_ip}"
}