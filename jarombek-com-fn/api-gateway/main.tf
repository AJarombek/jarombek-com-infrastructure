/**
 * Set up an API Gateway for a lambda function
 * Author: Andrew Jarombek
 * Date: 10/6/2018
 */

resource "aws_api_gateway_rest_api" "jarombek-com-api" {
  name = "JarombekComAPI"
  description = "A REST API for AWS Lambda Functions used with jarombek.com"
}

# Resource for the API path /welcome-email
resource "aws_api_gateway_resource" "jarombek-com-api-welcome-email" {
  rest_api_id = aws_api_gateway_rest_api.jarombek-com-api.id
  parent_id = aws_api_gateway_rest_api.jarombek-com-api.root_resource_id
  path_part = "welcome-email"
}

# Resource for the API path /welcome-email/{to}
resource "aws_api_gateway_resource" "jarombek-com-api-welcome-email-to" {
  rest_api_id = aws_api_gateway_rest_api.jarombek-com-api.id
  parent_id = aws_api_gateway_resource.jarombek-com-api-welcome-email.id
  path_part = "{to}"
}

resource "aws_api_gateway_method" "welcome-email-to-method" {
  rest_api_id = aws_api_gateway_rest_api.jarombek-com-api.id
  resource_id = aws_api_gateway_resource.jarombek-com-api-welcome-email-to.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  action = "lambda:InvokeFunction"
  function_name = var.lambda-function-name
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.jarombek-com-api.execution_arn}/*/*/*"
}