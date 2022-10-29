# creating new keypair in EC2
resource "aws_key_pair" "auth" {
  key_name   = "${ var.key_name }"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

# creating EC2 instance with given userdata to initialize the applications we need in this example
resource "aws_instance" "tier-guilherme" {
  ami = "${ data.aws_ami.coreos.id }"

  instance_type = "${ var.instance_type }"
  key_name      = "${ var.key_name }"

  source_dest_check           = false
  subnet_id                   = "${ aws_subnet.public_subnet.id }" # using a public subnet for external availability
  associate_public_ip_address = true                               # adding a public IP to it, so we can access from outside

  tags ={
    BuiltWith = "terraform"
    Name      = "3-tier-guilherme"
  }

  vpc_security_group_ids = ["${ aws_security_group.tier-security-group.id }"] # attaching security group

  user_data = "${ data.template_file.user_data.rendered }" # adding the user data
}

# resource that renders the userdata template
data "template_file" "user_data" {
  template = "${ file("user-data.tpl") }" # no extra variables here so just passing the plain file
}
