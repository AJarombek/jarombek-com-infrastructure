/**
 * Outputs for the AWS Lambda function for setting up emails
 * Author: Andrew Jarombek
 * Date: 3/28/2019
 */

output "function-name" {
  value = "${aws_lambda_function.welcome-email.function_name}"
}