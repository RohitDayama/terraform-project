
// creating ec2
resource "aws_instance" "project_instance" {
  instance_type = var.instance_type
  ami = var.ami_image
  subnet_id = aws_subnet.project_public_subnet.id
 vpc_security_group_ids = [ aws_default_security_group.default-sg2.id ]
  tags = {
    Name= var.instance_name 
  }
  associate_public_ip_address = true
  user_data  = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y openjdk-8-jdk  # Install Java (OpenJDK 8)
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get update
              sudo apt-get install -y jenkins        # Install Jenkins
              sudo systemctl start jenkins            # Start Jenkins service
              sudo systemctl enable jenkins           # Enable Jenkins service to start on boot
              
              sudo apt-get update
              sudo apt-get install -y openjdk-8-jdk  # Install Java (OpenJDK 8)
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get update
              sudo apt-get install -y jenkins        # Install Jenkins
              sudo systemctl start jenkins            # Start Jenkins service
              sudo systemctl enable jenkins           # Enable Jenkins service to start on boot

sudo apt update

# Install Nginx
sudo apt install -y nginx

# Start Nginx service
sudo systemctl start nginx

# Enable Nginx service to start on boot
sudo systemctl enable nginx

echo  "hello wrold" >/var/www/html/index.html
EOF

}

// creating VPC
resource "aws_vpc" "project_vpc" {
    cidr_block = var.cidr_block

    tags={
        Name=var.vpc_name
    }
}

//creating IGW
resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name=var.igw_name
  }
}

//Creating Subnets
resource "aws_subnet" "project_public_subnet" {
  vpc_id =  aws_vpc.project_vpc.id
  cidr_block = var.public_subnet_cidr
availability_zone = var.av_2
 map_public_ip_on_launch=var.map_public_ip_on_launch


  tags={
    Name=var.subnet_name
  }
}

resource "aws_subnet" "project_public_subnet-2" {
  vpc_id =  aws_vpc.project_vpc.id
  cidr_block = var.public_subnet_cidr-2
  availability_zone       =var.av_1

  tags={
    Name=var.subnet_name-1
  }
}
// route table
resource "aws_route_table" "project_route_table" {
  vpc_id =  aws_vpc.project_vpc.id
}
resource "aws_route" "p_r" {
    gateway_id = aws_internet_gateway.project_igw.id
    route_table_id = aws_route_table.project_route_table.id
    destination_cidr_block = "0.0.0.0/0"
  
}

//association
resource "aws_route_table_association" "project_route_ass" {
  subnet_id = aws_subnet.project_public_subnet.id
  route_table_id = aws_route_table.project_route_table.id
}

resource "aws_default_security_group" "default-sg2" {
  vpc_id =  aws_vpc.project_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}




resource "aws_lb" "my_load_balancer" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_default_security_group.default-sg2.id]
  subnets            = [aws_subnet.project_public_subnet.id, aws_subnet.project_public_subnet-2.id]
  





  tags = {
    Name = "MyLoadBalancer"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.project_vpc.id
  
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
   depends_on = [aws_lb_target_group_attachment.example_attachment]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }

}
resource "aws_lb_target_group_attachment" "example_attachment" {
 // count         = length(aws_instance.project_instance.*)
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.project_instance.id
}