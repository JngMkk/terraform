variable "names" {
  type    = list(string)
  default = ["a", "b", "c"]
}

resource "local_file" "count_ex" {
  count    = length(var.names)
  content  = "Count Example"
  filename = "${path.module}/count_ex_${var.names[count.index]}.txt" # 변수 인덱스에 직접 접근
}

resource "local_file" "count_ex2" {
  count    = length(var.names)
  content  = local_file.count_ex[count.index].content
  filename = "${path.module}/count_ex2_${element(var.names, count.index)}.txt" # element: list 형태의 목록에서 인덱스를 사용하여 단일 요소를 검색하는 함수
}