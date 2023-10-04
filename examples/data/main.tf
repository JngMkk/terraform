resource "local_file" "hello_world" {
  content = "Hello World!"
  filename = "${path.module}/hello_world.txt"
}

data "local_file" "hello_world" {
  filename = local_file.hello_world.filename
}

resource "local_file" "bye_world" {
  content = data.local_file.hello_world.content
  filename = "${path.module}/bye_world.txt"
}
