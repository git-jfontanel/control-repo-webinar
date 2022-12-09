
# variable "pe_platform" {
#   default = "el-7-x86_64"
# }

# variable "access_key" {
#   sensitive = true
# }

# variable "secret_key" {
#   sensitive = true
# }

# variable "session_token" {
# }

variable "pub_key" {
  description = "The public key name"
}

variable "profile" {
  default = "TSE"
}

variable "credentials" {
}

variable "region" {
  default = "eu-west-3"
}

# variable "aws_key_pair" {
# }

variable "termination_date" {
  description = "This is the termination date and what the AWS reaper will use to terminate"
  default     = "0000-00-00 00:00:00"
}


variable "name" {
}

variable "os" {
  description = "The OS version to search for" 
}

variable "amis_primary_owners" {
  description = "Force the ami Owner, could be (self) or specific (id)"
  default     = ""
}

variable "amis_os_map_regex" {
  description = "Map of regex to search amis"
  type        = map(string)
  default = {
    "centos-7"     = "^CentOS-7-2111"
    "centos-8"     = "^CentOS-Stream-ec2-8"
    "windows-2016" = "^Windows_Server-2016-English-Full-Base"
    "windows-2019" = "^Windows_Server-2019-English-Full-Base"
  }
}

variable "amis_os_map_owners" {
  description = "Map of amis owner to filter only official amis"
  type        = map(string)
  default     = {
    "centos-7"     = "679593333241"
    "centos-8"     = "679593333241"
    "windows-2016" = "801119661308" 
    "windows-2019" = "801119661308"     
  }
}

variable "instance_type" {
  description = "The instance type to be provisioned"
}

variable "map_instance_type" {
  description = "Map of the instance type"
  type        = map(string)
  default     = {
    "Gold"   = "t3.large"
    "Silver" = "t3.medium"
    "Bronze" = "t3.micro"
  } 
}

variable "domain" {
  default = "aws.tsedemos.com"
}

# variable "subnet" {
# }

# variable "sg_id" {
# }

variable "machines_count" {
  description = "This is the number of machines needed"
  default     = "0"
}

# variable "windows_count" {
#   description = "This is the number of Windows machines needed"
#   default     = "0"
# }
# variable "linux_count" {
#   description = "This is the number of Linux machines needed"
#   default     = "0"
# }

variable "primary_ip" {
}

variable "primary_name" {
  description = "FQDN primary Puppet server"
  default     = "puppet.se.automationdemos.com"
}

variable "role" {
  description = "Role of the server for Puppet classification"
}

variable "challengepassword" {
  description = "Password used for autosigning of the Puppet agent"
}
