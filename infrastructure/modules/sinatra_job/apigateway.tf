resource "aws_api_gateway_rest_api" "SinatraAPI" {
  name = "SinatraAPI"
  description = "This is sinatra application example"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.SinatraAPI.id}"
  parent_id   = "${aws_api_gateway_rest_api.SinatraAPI.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = "${aws_api_gateway_rest_api.SinatraAPI.id}"
  resource_id   = "${aws_api_gateway_rest_api.SinatraAPI.root_resource_id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.SinatraAPI.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = "${aws_api_gateway_rest_api.SinatraAPI.id}"
  resource_id             = "${aws_api_gateway_resource.proxy.id}"
  http_method             = "${aws_api_gateway_method.proxy.http_method}"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = "${aws_kinesis_stream.user_access_log.arn}"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/${var.apex_function_arns["sinatra_job"]}/invocations" 
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id             = "${aws_api_gateway_rest_api.SinatraAPI.id}"
  resource_id             = "${aws_api_gateway_rest_api.SinatraAPI.root_resource_id}"
  http_method             = "${aws_api_gateway_method.get.http_method}"
  type                    = "AWS_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  uri                     = "${aws_kinesis_stream.user_access_log.arn}"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/${var.apex_function_arns["sinatra_job"]}/invocations" 
}

resource "aws_api_gateway_deployment" "sinatra_job_deployment" {
  depends_on  = ["aws_api_gateway_rest_api.SinatraAPI"]
  rest_api_id = "${aws_api_gateway_rest_api.SinatraAPI.id}"
  stage_name  = "prod"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${var.apex_function_names["sinatra_job"]}"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.SinatraAPI.execution_arn}/*/*/*"
}