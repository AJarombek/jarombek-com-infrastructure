/**
 * EC2 instances for MongoDB
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

resource "mongodbatlas_project" "jarombek-com-db-project" {
  org_id = "andrew-jarombek"
  name = "jarombek-com-database-project"
}

resource "mongodbatlas_ip_whitelist" "jarombek-com-db-whitelist" {
  # Group simply means the project ID
  group = "${mongodbatlas_project.jarombek-com-db-project.id}"
  cidr_block = "${var.cidr_whitelist}"
  comment = "VPC CIDR"
}

resource "mongodbatlas_cluster" "jarombek-com-db-cluster" {
  name = "jarombek-com-database-cluster"
  group = "${mongodbatlas_project.jarombek-com-db-project.id}"
  mongodb_major_version = "4.0"
  provider_name = "${var.provider_name}"
  region = "${var.region}"

  # Size of the instance.  M2 is the smallest piad instance option
  size = "M2"

  # M2 instances do not support continual backups
  backup = false

  # Specifies whether disk auto scaling is enabled
  disk_gb_enabled = false

  # The number of replica set members.  Each member has a copy of the database.
  # M0 instances only support 3 nodes, while instances greater than M5 support 3, 5, and 7
  replication_factor = 3
}

# A container resource represents an AWS VPC in the MongoDB Atlas netowrk.  This VPC can be used for VPC peering.
# Only one container can exist for a project in each region.  In order to use VPC peering, the size of the MongoDB
# instance must be >= M10.
resource "mongodbatlas_container" "jarombek-com-db-container" {
  group = "${mongodbatlas_project.jarombek-com-db-project.id}"
  atlas_cidr_block = "${}" # TODO
  provider_name = "${var.provider_name}"
  region = "${var.region}"
}

resource "mongodbatlas_database_user" "andy" {
  username = "andy"
  password = "${var.database_user_andy_password}"
  database = "jarombekcom"
  group = "${mongodbatlas_project.jarombek-com-db-project.id}"

  roles {
    name = "readWrite"
    database = "jarombekcom"
  }
}