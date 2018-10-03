/**
 * Get the ID of an AMI with the provided filters
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

data "aws_ami" "linux-latest" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "root-device-type"
    # EBS (Elastic Block Store) device persists the root device from an EC2 instance into an EBS store.
    # If an instance goes down, the EBS store still exists and is remounted when the instance comes back up.
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    # HVM (Hardware Virtual Machine) enables an operating system to run unchanged on top of a virtual machine,
    # as if the VM were the bare metal hardware.  HVM is generally the faster form of virtualization.
    values = ["hvm"]
  }

  filter {
    name = "block-device-mapping.volume-type"
    # The type of volume used for EBS storage.  gp2 is a general purpose SSD
    values = ["gp2"]
  }
}