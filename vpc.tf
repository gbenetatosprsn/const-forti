resource "aws_vpc" "fgtvm-vpc" {
  cidr_block           = var.vpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = join("", [var.coid, "-", var.region, "-vpc00-fw"])
  }
}

resource "aws_subnet" "publicsubnetaz1" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.publiccidraz1
  availability_zone = var.az1
  tags = {
    Name = join("", [var.coid, "-", var.region, "-public-AZ1"])
  }
}

resource "aws_subnet" "publicsubnetaz2" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.publiccidraz2
  availability_zone = var.az2
  tags = {
    Name = join("", [var.coid, "-", var.region, "-public-AZ2"])
  }
}


resource "aws_subnet" "privatesubnetaz1" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.privatecidraz1
  availability_zone = var.az1
  tags = {
    Name = join("", [var.coid, "-", var.region, "-private-AZ1"])
  }
}

resource "aws_subnet" "privatesubnetaz2" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.privatecidraz2
  availability_zone = var.az2
  tags = {
    Name = join("", [var.coid, "-", var.region, "-private-AZ2"])
  }
}

resource "aws_subnet" "hasyncsubnetaz1" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.hasynccidraz1
  availability_zone = var.az1
  tags = {
    Name = join("", [var.coid, "-", var.region, "-HA-AZ1"])
  }
}

resource "aws_subnet" "hasyncsubnetaz2" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.hasynccidraz2
  availability_zone = var.az2
  tags = {
    Name = join("", [var.coid, "-", var.region, "-HA-AZ2"])
  }
}

resource "aws_subnet" "hamgmtsubnetaz1" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.hamgmtcidraz1
  availability_zone = var.az1
  tags = {
    Name = join("", [var.coid, "-", var.region, "-MNG-AZ1"])
  }
}

resource "aws_subnet" "hamgmtsubnetaz2" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.hamgmtcidraz2
  availability_zone = var.az2
  tags = {
    Name = join("", [var.coid, "-", var.region, "-MNG-AZ2"])
  }
}

resource "aws_subnet" "tgwaz1" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.tgwaz1ip
  availability_zone = var.az1
  tags = {
    Name = join("", [var.coid, "-", var.region, "-TGW-AZ1"])
  }
}

resource "aws_subnet" "tgwaz2" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.tgwaz2ip
  availability_zone = var.az2
  tags = {
    Name = join("", [var.coid, "-", var.region, "-TGW-AZ2"])
  }
}