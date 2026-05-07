# ─── RDS Subnet Group ─────────────────────
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "RDS_Subnet_Group" }
}


# ─── RDS Instance ──────────────────────────────
resource "aws_db_instance" "postgres" {
  identifier        = var.identifier
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = "django_app"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.RDS_SG_id]

  skip_final_snapshot = true
  multi_az            = false

  tags = { Name = "DjangoApp_RDS" }
}
