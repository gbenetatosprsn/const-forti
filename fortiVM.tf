resource "aws_network_interface" "eth0" {
  description = "Public-AZ1"
  subnet_id   = aws_subnet.publicsubnetaz1.id
  private_ips = [var.activeport1]
}

resource "aws_network_interface" "eth1" {
  description       = "Private-AZ1"
  subnet_id         = aws_subnet.privatesubnetaz1.id
  private_ips       = [var.activeport2]
  source_dest_check = false
}


resource "aws_network_interface" "eth2" {
  description       = "HA-AZ1"
  subnet_id         = aws_subnet.hasyncsubnetaz1.id
  private_ips       = [var.activeport3]
  source_dest_check = false
}


resource "aws_network_interface" "eth3" {
  description = "MNG-AZ1"
  subnet_id   = aws_subnet.hamgmtsubnetaz1.id
  private_ips = [var.activeport4]
}


resource "aws_network_interface_sg_attachment" "publicattachment" {
  depends_on           = [aws_network_interface.eth0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.eth0.id
}


resource "aws_network_interface_sg_attachment" "mgmtattachment" {
  depends_on           = [aws_network_interface.eth3]
  security_group_id    = aws_security_group.MNG_allow.id
  network_interface_id = aws_network_interface.eth3.id
}

resource "aws_network_interface_sg_attachment" "internalattachment" {
  depends_on           = [aws_network_interface.eth1]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth1.id
}

resource "aws_network_interface_sg_attachment" "hasyncattachment" {
  depends_on           = [aws_network_interface.eth2]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth2.id
}


resource "aws_instance" "fgtactive" {
  //it will use region, architect, and license type to decide which ami to use for deployment
  depends_on        = [aws_key_pair.firewall,aws_iam_instance_profile.ec2_profile]
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.size
  availability_zone = var.az1
  key_name          = "firewall"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.eth0.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eth1.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.eth2.id
    device_index         = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.eth3.id
    device_index         = 3
  }


  tags = {
    Name = join ("", [var.coid, "-AWS", "E", "FT01-A"])
  }
}

resource "aws_network_interface" "passiveeth0" {
  description = "Public-AZ2"
  subnet_id   = aws_subnet.publicsubnetaz2.id
  private_ips = [var.passiveport1]
}

resource "aws_network_interface" "passiveeth1" {
  description       = "Private-AZ2"
  subnet_id         = aws_subnet.privatesubnetaz2.id
  private_ips       = [var.passiveport2]
  source_dest_check = false
}


resource "aws_network_interface" "passiveeth2" {
  description       = "HA-AZ2"
  subnet_id         = aws_subnet.hasyncsubnetaz2.id
  private_ips       = [var.passiveport3]
  source_dest_check = false
}


resource "aws_network_interface" "passiveeth3" {
  description = "MNG-AZ2"
  subnet_id   = aws_subnet.hamgmtsubnetaz2.id
  private_ips = [var.passiveport4]
}


resource "aws_network_interface_sg_attachment" "passivepublicattachment" {
  depends_on           = [aws_network_interface.passiveeth0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.passiveeth0.id
}


resource "aws_network_interface_sg_attachment" "passivemgmtattachment" {
  depends_on           = [aws_network_interface.passiveeth3]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.passiveeth3.id
}

resource "aws_network_interface_sg_attachment" "passiveinternalattachment" {
  depends_on           = [aws_network_interface.passiveeth1]
  security_group_id    = aws_security_group.MNG_allow.id
  network_interface_id = aws_network_interface.passiveeth1.id
}

resource "aws_network_interface_sg_attachment" "passivehasyncattachment" {
  depends_on           = [aws_network_interface.passiveeth2]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.passiveeth2.id
}


resource "aws_instance" "fgtpassive" {
  depends_on        = [aws_instance.fgtactive,aws_key_pair.firewall,aws_iam_instance_profile.ec2_profile]
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.size
  availability_zone = var.az2
  key_name          = "firewall"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.passiveeth0.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.passiveeth1.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.passiveeth2.id
    device_index         = 2
  }

  network_interface {
    network_interface_id = aws_network_interface.passiveeth3.id
    device_index         = 3
  }


  tags = {
    Name = join ("", [var.coid, "-AWS", "W", "FT01-B"])
  }
}