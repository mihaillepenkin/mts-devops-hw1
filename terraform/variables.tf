variable "docker_host" {
  description = "SSH-адрес Docker на VM"
  type        = string
  default     = "ssh://deployer@111.88.162.77"
}
variable "ssh_key_path" {
  description = "Путь к приватному SSH-ключу"
  type        = string
  default     = "~/.ssh/mts_devops"
}
variable "external_port" {
  description = "Внешний порт nginx на VM"
  type        = number
  default     = 8080
}
