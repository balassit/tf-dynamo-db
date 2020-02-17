locals {
  attributes = [
    {
      name = "${var.range_key}"
      type = "${var.range_key_type}"
    },
    {
      name = "${var.partition_key}"
      type = "${var.partition_key_type}"
    },
    ["${var.extra_attributes}"],
  ]

  # Use the `slice` pattern (instead of `conditional`) to remove the first map from the list if no `range_key` is provided
  # Terraform does not support conditionals with `lists` and `maps`: aws_dynamodb_table.default: conditional operator cannot be used with list values
  from_index = "${length(var.range_key) > 0 ? 0 : 1}"

  attributes_final = "${slice(local.attributes, local.from_index, length(local.attributes))}"
}

resource "null_resource" "global_secondary_index_names" {
  count = "${length(var.global_secondary_index_map)}"

  # Convert the multi-item `global_secondary_index_map` into a simple `map` with just one item `name` since `triggers` does not support `lists` in `maps` (which are used in `non_key_attributes`)
  # https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html#non_key_attributes-1
  triggers = "${map("name", lookup(var.global_secondary_index_map[count.index], "name"))}"
}

resource "null_resource" "local_secondary_index_names" {
  count = "${length(var.local_secondary_index_map)}"

  # Convert the multi-item `local_secondary_index_map` into a simple `map` with just one item `name` since `triggers` does not support `lists` in `maps` (which are used in `non_key_attributes`)`
  # https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html#non_key_attributes-1
  triggers = "${map("name", lookup(var.local_secondary_index_map[count.index], "name"))}"
}

resource "aws_dynamodb_table" "us_east_1_table" {
  provider     = "aws.us-east-1"
  hash_key     = "${var.partition_key}"
  range_key    = "${var.range_key}"
  billing_mode = "${var.billing_mode}"
  name         = "${var.table_name}"
  point_in_time_recovery {
    enabled = true
  }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled = true
  }

  attribute              = ["${local.attributes_final}"]
  global_secondary_index = ["${var.global_secondary_index_map}"]
  local_secondary_index  = ["${var.local_secondary_index_map}"]

  tags = "${merge(
    var.tags,
    map("Name", "${var.table_name}")
  )}"
}

resource "aws_dynamodb_table" "us_west_2_table" {
  provider     = "aws.us-west-2"
  hash_key     = "${var.partition_key}"
  range_key    = "${var.range_key}"
  billing_mode = "${var.billing_mode}"
  name         = "${var.table_name}"
  point_in_time_recovery {
    enabled = true
  }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  server_side_encryption {
    enabled = true
  }

  attribute              = ["${local.attributes_final}"]
  global_secondary_index = ["${var.global_secondary_index_map}"]
  local_secondary_index  = ["${var.local_secondary_index_map}"]

  tags = "${merge(
    var.tags,
    map("Name", "${var.table_name}")
  )}"
}

resource "aws_dynamodb_global_table" "global_table" {
  provider   = "aws.us-east-1"
  name       = "${var.table_name}"
  depends_on = ["aws_dynamodb_table.us_east_1_table", "aws_dynamodb_table.us_west_2_table"]

  replica {
    region_name = "us-east-1"
  }

  replica {
    region_name = "us-west-2"
  }
}