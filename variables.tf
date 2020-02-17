variable "partition_key" {
  description = "The key with which to partition (hash) the data."
  type        = string
}

variable "partition_key_type" {
  description = "The type of the partitionKey. Valid values are 'S', 'N', or 'B' for (S)tring, (N)umber or (B)inary data"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "The key with which to partition (hash) the data."
  type        = string
  default     = ""
}

variable "range_key_type" {
  description = "The type of the partitionKey. Valid values are 'S', 'N', or 'B' for (S)tring, (N)umber or (B)inary data"
  type        = string
  default     = "S"
}

variable "enable_autoscaling" {
  description = "The arn of the IAM role to use for autoscaling"
  type        = string
  default     = "false"
}

variable "extra_attributes" {
  description = "Additional DynamoDB attributes in the form of a list of mapped values"
  type        = list(string)
  default     = []
}

variable "global_secondary_index_map" {
  description = "Additional global secondary indexes in the form of a list of mapped values, eg "

  # Example:
  #  global_secondary_index_map = [
  #   {
  #     name               = "GSIName"
  #     hash_key           = "HashKey1"
  #     range_key          = "RangeKey1"
  #     write_capacity     = 5
  #     read_capacity      = 5
  #     projection_type    = "INCLUDE"
  #     non_key_attributes = ["SomeOtherKey", "SomeRandomKey"]
  #   },
  #   ...
  # ]
  type    = list(string)
  default = []
}

variable "local_secondary_index_map" {
  description = "Additional local secondary indexes in the form of a list of mapped values"

  # See global_secondary_index_map for a similar example (specific fields will vary)
  type    = list(string)
  default = []
}

variable "autoscaling_role_arn" {
  description = "The arn of the IAM role to use for autoscaling"
  type        = string
  default     = ""
}

variable "billing_mode" {
  description = "The valid values are PROVISIONED and PAY_PER_REQUEST. Defaults to PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "table_name" {
  description = "Name of the dynamo table."
  type        = string
}

variable "read_capacity" {
  description = "How much read capacity in units to give to the dynamo tables"
  type        = string
  default     = "10"
}

variable "write_capacity" {
  description = "How much write capacity in units to give to the dynamo tables"
  type        = string
  default     = "10"
}

variable "env" {
  description = "The environment to deploy e.g. dev"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the object"
  type        = map(string)
  default     = {}
}

