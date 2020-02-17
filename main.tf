provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias = "us-west-2"
  region = "us-west-2"
}

locals {
  attributes = flatten([
    {
      name = var.range_key
      type = var.range_key_type
    },
    {
      name = var.partition_key
      type = var.partition_key_type
    }
  , var.extra_attributes])

  # Use the slice pattern (instead of conditional) to remove the first map from the list if no range_key is provided
  # Terraform does not support conditionals with lists and maps: aws_dynamodb_table.default: conditional operator cannot be used with list values
  from_index = var.range_key == "" ? 1 : 0

  attributes_final = slice(local.attributes, local.from_index, length(local.attributes))
}

resource "aws_dynamodb_table" "us_east_1_table" {
  provider     = aws.us-east-1
  hash_key     = var.partition_key
  range_key    = var.range_key
  billing_mode = var.billing_mode
  name         = var.table_name
  point_in_time_recovery {
    enabled = true
  }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled = true
  }

  dynamic "attribute" {
    for_each = local.attributes_final
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index_map
    content {
      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      non_key_attributes = global_secondary_index.value.non_key_attributes
      projection_type    = global_secondary_index.value.projection_type
      range_key          = global_secondary_index.value.range_key
      read_capacity      = global_secondary_index.value.read_capacity
      write_capacity     = global_secondary_index.value.write_capacity
    }
  }
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_index_map
    content {
      name               = local_secondary_index.value.name
      non_key_attributes = local_secondary_index.value.non_key_attributes
      projection_type    = local_secondary_index.value.projection_type
      range_key          = local_secondary_index.value.range_key
    }
  }


  tags = merge(
    var.tags,
    {
      "Name" = var.table_name
    },
  )
}

resource "aws_dynamodb_table" "us_west_2_table" {
  provider     = aws.us-west-2
  hash_key     = var.partition_key
  range_key    = var.range_key
  billing_mode = var.billing_mode
  name         = var.table_name
  point_in_time_recovery {
    enabled = true
  }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  server_side_encryption {
    enabled = true
  }

  dynamic "attribute" {
    for_each = local.attributes_final
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index_map
    content {
      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      non_key_attributes = global_secondary_index.value.non_key_attributes
      projection_type    = global_secondary_index.value.projection_type
      range_key          = global_secondary_index.value.range_key
      read_capacity      = global_secondary_index.value.read_capacity
      write_capacity     = global_secondary_index.value.write_capacity
    }
  }
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_index_map
    content {
      name               = local_secondary_index.value.name
      non_key_attributes = local_secondary_index.value.non_key_attributes
      projection_type    = local_secondary_index.value.projection_type
      range_key          = local_secondary_index.value.range_key
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.table_name
    },
  )
}

resource "aws_dynamodb_global_table" "global_table" {
  provider = aws.us-east-1
  name     = var.table_name
  depends_on = [
    aws_dynamodb_table.us_east_1_table,
    aws_dynamodb_table.us_west_2_table,
  ]

  replica {
    region_name = "us-east-1"
  }

  replica {
    region_name = "us-west-2"
  }
}
