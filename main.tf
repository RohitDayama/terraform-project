
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
  user_data  = file("jenkins-server-script.sh")


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


