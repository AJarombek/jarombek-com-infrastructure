/**
 * The AWS Lambda function for setting up emails
 * Author: Andrew Jarombek
 * Date: 10/6/2018
 */

resource "aws_lambda_function" "welcome-email" {
  function_name = "sendWelcomeEmail"
  filename = "${path.module}/welcomeEmail.zip"
  handler = "sendEmailAWS.sendWelcomeEmail"
  role = aws_iam_role.lambda-role.arn
  runtime = "nodejs12.x"
  source_code_hash = filebase64sha256("${path.module}/welcomeEmail.zip")

  tags = {
    Name = "jarombek-com-lambda-welcome-email"
    Environment = "production"
    Application = "jarombek-com"
  }
}

resource "aws_cloudwatch_log_group" "welcome-email-log-group" {
  name = "/aws/lambda/sendWelcomeEmail"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda-role" {
  name = "iam-lambda-role"
  assume_role_policy = file("${path.module}/lambda-role.json")
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name = "lambda-logging-policy"
  path = "/jarombek-com/"
  policy = file("${path.module}/lambda-logging-policy.json")
  description = "IAM policy for logging from an AWS Lambda function"
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role = aws_iam_role.lambda-role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}