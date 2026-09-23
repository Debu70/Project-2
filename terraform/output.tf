output "ec2_instances" {
  description = "EC2 instance details"

  value = [
    for instance in aws_instance.app_server : {
      name          = instance.tags["Name"]
      instance_type = instance.instance_type
      public_ip     = instance.public_ip
      private_ip    = instance.private_ip
    }
  ]
}
