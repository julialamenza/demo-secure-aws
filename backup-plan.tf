# backup-plan.tf
resource "aws_backup_vault" "main" {
  name = "veeam-backup-vault"
}

resource "aws_backup_plan" "plan" {
  name = "ec2-backup-plan"
  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 12 * * ? *)"
  }
}
