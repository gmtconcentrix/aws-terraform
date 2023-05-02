data "aws_ami" "instance-ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "template_file" "ec2-bootstrap-script" {
  template = file("./ec2-bootstrap-script.sh")
}

resource "aws_key_pair" "gtm-key-pair" {
  key_name   = "gtm-key"
  public_key = file("~/.ssh/gmtkey.pub")
  tags = {
    Name = "ec2-gtm-keypair"
  }
}

resource "aws_instance" "ec2-instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.instance-ami.id
  vpc_security_group_ids = [aws_security_group.ec2-sec-group-id.id]
  subnet_id              = aws_subnet.gtm-vpc-public-subnet.id
  key_name               = aws_key_pair.gtm-key-pair.id

  root_block_device {
    volume_size = 10
  }
  user_data = data.template_file.ec2-bootstrap-script.rendered
  tags = {
    Name = "ec2-instance"
  }
}