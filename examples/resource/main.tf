/*
리소스 인수 참조 활용 예

k8s 프로바이더의 Namespace 리소스를 생성하고
그 이후 Secret을 해당 Namespace에 생성하는 종속성을 리소스 인수 값으로 생성하는 예.

Namespace의 이름만 변경해도,
해당 Namespace를 참조하는 모든 리소스가 업데이트되어 영향을 받게 되는 참조의 효과.
*/
resource "kubernetes_namespace" "k8s_ns_ex" {
  metadata {
    annotations = {
      name = "ns-annotation-ex"
    }
    name = "tf-ns-ex"
  }
}

resource "kubernetes_secret" "k8s_sec_ex" {
  metadata {
    namespace = kubernetes_namespace.k8s_ns_ex.metadata.0.name      # namespace 리소스 인수 참조
    name = "sc-ex"
  }
  data = {
    password = "Passw0rd"
  }
}

/*
AWS 프로바이더의 가용영역을 작업자가 수동으로 입력하지 않고
프로바이더로 접근한 환경에서 제공되는 데이터 소스를 활용해 subnet의 가용영역 인수를 정의하는 예.

데이터 소스를 활용해 AWS 프로바이더에 구성된 Region 내에서 사용 가능한 가용영역 목록을 읽을 수 있음.
*/
data "aws_availability_zones" "AZ" {
  state = "available"
}

resource "aws_subnet" "primary" {
  availability_zone = data.aws_availability_zones.AZ.names[0]       # ap-northeast-2a
}

resource "aws_subnet" "secondary" {
  availability_zone = data.aws_availability_zones.AZ.names[1]       # ap-northeast-2b
}
