# Provision the ec2 instance for NGINX
resource "aws_instance" "nginx-server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2-server.key_name
  vpc_security_group_ids = [aws_security_group.general-sg.id]
  user_data              = data.template_file.nginx_data_script.rendered

  tags = {
    "Name" = "nginx-server"
  }
}

# Provision the ec2 instance for APACHE
resource "aws_instance" "apache-server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2-server.key_name
  vpc_security_group_ids = [aws_security_group.general-sg.id]
  user_data              = data.template_file.apache_data_script.rendered

  tags = {
    "Name" = "apache-server"
  }
}

