/**
 * Author: Andrew Jarombek
 * Date: 10/6/2018
 */

output "lambda_function_name" {
  value = "${aws_lambda_function.welcome-email.arn}"
}