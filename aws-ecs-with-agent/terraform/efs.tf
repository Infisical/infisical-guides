resource "aws_efs_file_system" "infisical_efs" {
  tags = {
    Name = "INFISICAL-ECS-EFS"
  }
}

resource "aws_efs_mount_target" "mount" {
  count           = length(aws_subnet.private.*.id)
  file_system_id  = aws_efs_file_system.infisical_efs.id
  subnet_id       = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}
