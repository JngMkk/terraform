resource "local_file" "hello_world" {
  content  = "Hello World!"
  filename = "${path.module}/hello_world.txt"
}

output "file_id" {
  value = local_file.hello_world.id
}

output "file_abspath" {
  value = abspath(local_file.hello_world.filename)
}