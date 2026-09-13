variable "namespace" {
  description = "Repository prefix, e.g. loyaone."
  type        = string
  default     = "loyaone"
}

variable "repositories" {
  description = "Service names to create repositories for."
  type        = list(string)
}

variable "keep_last_images" {
  description = "Tagged images to retain per repository."
  type        = number
  default     = 30
}

variable "force_delete" {
  description = "Delete repositories even if they contain images. Dev only."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "KMS key for image encryption. Null uses AES256."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
