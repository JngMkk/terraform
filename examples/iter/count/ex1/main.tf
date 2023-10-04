resource "local_file" "count_ex" {
  count    = 5
  content  = "Count Example${count.index}"
  filename = "${path.module}/count_ex${count.index}.txt"
}