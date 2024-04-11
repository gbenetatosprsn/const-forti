#Create TGW

resource "aws_ec2_transit_gateway" "main_tgw" {
  description                                           = "TGW"
  auto_accept_shared_attachments                        = "enable"
  default_route_table_association                       = "disable"
  default_route_table_propagation                       = "disable"
  tags = {
   Name                                                 = join("", [var.coid, "-", var.region, "-TGW"])
  }
}

#Create TGW attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-main" {
  depends_on                                            = [aws_ec2_transit_gateway.main_tgw]
  subnet_ids                                            = [aws_subnet.tgwaz1,aws_subnet.tgwaz2]
  transit_gateway_id                                    = aws_ec2_transit_gateway.main_tgw.id
  transit_gateway_default_route_table_association       = false
  transit_gateway_default_route_table_propagation       = false
  vpc_id                                                = aws_vpc.fgtvm-vpc.id
  appliance_mode_support                                = "enable"
  tags = {
   Name                                                 = join("", [var.coid, "-", var.region, "-securityVPC-Attach"])
  }
}

#Creating TGW RT

resource "aws_ec2_transit_gateway_route_table" "inboundvpc" {
  depends_on                                    = [aws_ec2_transit_gateway_vpc_attachment.tgw-main,aws_ec2_transit_gateway.main_tgw]
  transit_gateway_id                            = aws_ec2_transit_gateway.main_tgw.id
  tags = {
   Name                                                 = join("", [var.coid, "-TGW-RT"])
  }
}

#Associate RT


resource "aws_ec2_transit_gateway_route_table_association" "associate_vpc" {
  depends_on                                    = [aws_ec2_transit_gateway.main_tgw,aws_ec2_transit_gateway_route_table.inboundvpn]
  transit_gateway_attachment_id                 = aws_ec2_transit_gateway_vpc_attachment.tgw-main.id
  transit_gateway_route_table_id                = aws_ec2_transit_gateway_route_table.inboundvpn.id
}
