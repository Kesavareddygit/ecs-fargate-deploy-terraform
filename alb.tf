resource "aws_lb_target_group" "betaflux-test-tg" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name                  = "${var.env}-betaflux-test-tg"
  port                  = 80
  protocol              = "HTTP"
  target_type           = "ip"
  vpc_id                = aws_vpc.betaflux-test-vpc.id
}

resource "aws_lb" "betaflux-test-alb" {
  name               = "${var.env}-betaflux-test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.betaflux-test.id]
  subnets            = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]
  ip_address_type    = "ipv4"


  tags = {
    Name = "${var.env}-betaflux-test-alb"
  }
}

resource "aws_lb_listener" "betaflux-test-alb" {
  load_balancer_arn = aws_lb.betaflux-test-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.betaflux-test-tg.arn
  }
}
