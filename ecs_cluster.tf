resource "aws_ecs_cluster" "kesava-ecs" {
  name = "${var.name}-cluster"
  tags = {
    Name        = "${var.name}-cluster"
  }
}
