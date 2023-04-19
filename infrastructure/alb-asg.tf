# Load Balancers and component declaration
resource "aws_lb_target_group" "terraform-one-tg" {
  name        = "terraform-one-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    enabled             = true
  }
}

resource "aws_lb" "terraform-one-lb" {
  name               = "terraform-one-lb"
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.general-sg.id]
  subnets            = data.aws_subnets.subnets.ids
}

resource "aws_lb_listener" "terraform-one-lbl" {
  load_balancer_arn = aws_lb.terraform-one-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform-one-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "nginx-server" {
  target_group_arn = aws_lb_target_group.terraform-one-tg.arn
  target_id        = aws_instance.nginx-server.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "apache-server" {
  target_group_arn = aws_lb_target_group.terraform-one-tg.arn
  target_id        = aws_instance.apache-server.id
  port             = 80
}

# ASG and component declaretion
resource "aws_launch_template" "nginx-lt" {
  name                   = "nginx-lt"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.general-sg.id]
  user_data              = base64encode(data.template_file.nginx_data_script.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name : "nginx-lt"
    }
  }
}

resource "aws_launch_template" "apache-lt" {
  name                   = "apache-lt"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.general-sg.id]
  user_data              = base64encode(data.template_file.apache_data_script.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name : "apache-lt"
    }
  }
}

resource "aws_autoscaling_group" "terraform-one-asg" {
  name                      = "terraform-one-asg"
  vpc_zone_identifier       = aws_lb.terraform-one-lb.subnets
  max_size                  = 10
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.terraform-one-tg.arn]

  launch_template {
    id      = aws_launch_template.nginx-lt.id
    version = "$Latest"
  }
}
