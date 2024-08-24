terraform {
  required_version = "1.8.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }
  }
  encryption {
    key_provider "pbkdf2" "new" {
      passphrase = "this-that-those-them-there-their-theyre"
    }

    method "aes_gcm" "new" {
      keys = key_provider.pbkdf2.new
    }

    state {
      method = method.aes_gcm.new
    }

    plan {
      method = method.aes_gcm.new
    }
  }
}