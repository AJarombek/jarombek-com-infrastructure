/**
 * EC2 instances for MongoDB
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

resource "mongodbatlas_project" "jarombek-com-database-project" {
  org_id = "andrew-jarombek"
  name = "jarombek-com-database-project"
}

resource "mongodbatlas_cluster" "jarombek-com-database-cluster" {
  name = "jarombek-com-database-cluster"
  group = "${mongodbatlas_project.jarombek-com-database-project.id}"
  mongodb_major_version = "3.6"
  provider_name = "TENANT"
  backing_provider = "AWS"
}