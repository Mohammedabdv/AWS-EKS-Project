variable "ecr_repository_name" {
  type    = string
  default = "my-app-repo"
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the ECR repository. MUTABLE allows pushing new images with the same tag (e.g., 'latest'), while IMMUTABLE prevents overwriting existing tags."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether to scan images when pushed to the repository."
  type        = bool
  default     = true
}

variable "encryption_type" {
  type    = string
  default = "AES256"
}

