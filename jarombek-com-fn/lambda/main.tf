/**
 * The AWS Lambda function for setting up emails
 * Author: Andrew Jarombek
 * Date: 10/6/2018
 */

data "archive_file" "lambda" {
  source_file = "welcomeEmail.js"
  output_path = "welcomeEmail.zip"
  type = "zip"
}

resource "aws_lambda_function" "welcome-email" {
  function_name = "sendWelcomeEmail"
  filename = "welcomeEmail.zip"
  handler = "sendEmailAWS.sendWelcomeEmail"
  role = aws_iam_role.lambda-role.arn
  runtime = "nodejs8.10"
  source_code_hash = base64sha256(file("${data.archive_file.lambda.output_path}"))
}

resource "aws_iam_role" "lambda-role" {
  name = "iam-lambda-role"
  assume_role_policy = file("${path.module}/lambdaRole.json")
}