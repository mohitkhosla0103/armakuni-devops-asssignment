locals {
  

  userdata_script = <<-EOT
    #!/bin/bash
    sudo yum update -y
    echo "ECS_CLUSTER=enter-cluster-name" | sudo tee -a /etc/ecs/ecs.config
  EOT

  encoded_userdata = base64encode(local.userdata_script)
}