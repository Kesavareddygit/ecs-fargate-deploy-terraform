output "alb_hostname" {
  value = aws_lb.betaflux-test-alb.dns_name
}


output "aws_ecr_repository_url" {
    value = aws_ecr_repository.main.repository_url
}
