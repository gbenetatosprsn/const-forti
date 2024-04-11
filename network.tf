resource "aws_internet_gateway" "fgtvmigw" {
  vpc_id = aws_vpc.fgtvm-vpc.id
  tags = {
    Name = join("", [var.coid, "-", var.region, "-IGW"])
  }
}

// Route Table
resource "aws_route_table" "fgtvmpublicrt" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = join("", [var.coid, "-", var.region, "-Public-rt"])
  }
}

resource "aws_route_table" "fgtvmtgwrt" {
  depends_on             = [aws_instance.fgtactive]
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = join("", [var.coid, "-", var.region, "-TGW-rt"])
  }
}

resource "aws_route_table" "fgtvmprivatert" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = join("", [var.coid, "-", var.region, "-Private-rt"])
  }
}


resource "aws_route" "externalroute" {
  route_table_id         = aws_route_table.fgtvmpublicrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fgtvmigw.id
}

resource "aws_route" "internalroute" {
  depends_on             = [aws_instance.fgtactive]
  route_table_id         = aws_route_table.fgtvmprivatert.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.eth1.id

}

resource "aws_route_table_association" "public1associate" {
  subnet_id      = aws_subnet.publicsubnetaz1.id
  route_table_id = aws_route_table.fgtvmpublicrt.id
}


resource "aws_route_table_association" "public2associate" {
  subnet_id      = aws_subnet.publicsubnetaz2.id
  route_table_id = aws_route_table.fgtvmpublicrt.id
}

resource "aws_route_table_association" "hamgmt1associate" {
  subnet_id      = aws_subnet.hamgmtsubnetaz1.id
  route_table_id = aws_route_table.fgtvmpublicrt.id
}

resource "aws_route_table_association" "hamgmt2associate" {
  subnet_id      = aws_subnet.hamgmtsubnetaz2.id
  route_table_id = aws_route_table.fgtvmpublicrt.id
}

resource "aws_route_table_association" "internalassociate" {
  subnet_id      = aws_subnet.privatesubnetaz1.id
  route_table_id = aws_route_table.fgtvmprivatert.id
}

resource "aws_route_table_association" "internal2associate" {
  subnet_id      = aws_subnet.privatesubnetaz2.id
  route_table_id = aws_route_table.fgtvmprivatert.id
}

resource "aws_route_table_association" "tgw1associate" {
  subnet_id      = aws_subnet.tgwaz1.id
  route_table_id = aws_route_table.fgtvmtgwrt.id
}
resource "aws_route_table_association" "tgw21associate" {
  subnet_id      = aws_subnet.tgwaz2.id
  route_table_id = aws_route_table.fgtvmtgwrt.id
}

resource "aws_eip" "ClusterPublicIP" {
  depends_on        = [aws_instance.fgtactive]
  network_interface = aws_network_interface.eth0.id
}


resource "aws_eip" "MGMTPublicIP" {
  depends_on = [aws_instance.fgtactive]
  //depends_on        = [aws_network_interface.eth3]
  network_interface = aws_network_interface.eth3.id
}

resource "aws_eip" "PassiveMGMTPublicIP" {
  depends_on = [aws_instance.fgtpassive]
  //depends_on        = [aws_network_interface.passiveeth3]
  network_interface = aws_network_interface.passiveeth3.id
}




// Security Group

resource "aws_security_group" "MNG_allow" {
  name        = "MNG Allow"
  description = "Public Allow traffic"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12","100.70.0.0/15","52.147.201.44/32","207.223.34.132/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12","100.70.0.0/15","52.147.201.44/32","207.223.34.132/32"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "6"
    cidr_blocks = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12","100.70.0.0/15","52.147.201.44/32","207.223.34.132/32"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("", [var.coid, "-", var.region, "-Fortigate-MNG-SG"])
  }
}

resource "aws_security_group" "allow_all" {
  name        = "Private"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12","100.70.0.0/15"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("", [var.coid, "-", var.region, "-Fortigate-Private-SG"])
  }
}

resource "aws_security_group" "public_allow" {
  name        = "Public All"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = join("", [var.coid, "-", var.region, "-Fortigate-Public-SG"])
  }
}