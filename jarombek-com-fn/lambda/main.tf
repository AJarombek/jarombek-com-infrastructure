/**
 * The AWS Lambda function for setting up emails
 * Author: Andrew Jarombek
 * Date: 10/6/2018
 */

data "archive_file" "lambda" {
  source_file = "email.js"
  output_path = "email.zip"
  type = "zip"
}