package envoy.authz

import input.attributes.request.http as http_request
import input.attributes.request.http.headers as headers

default allow = false

allow = response {
  http_request.method == "GET"
  headers.token == "admin"
  response := {
    "allowed": true,
    "headers": {"x-secure": "admin"}
  }
}

allow = response {
  http_request.method == "GET"
  headers.token != "admin"

  response := {
    "allowed": true,
    "headers": {"x-secure": "user"}
  }
}

allow = response {
  http_request.method == "POST"
  headers.clientip == "192.168.252.20"
  response := {
    "allowed": true,
    "headers": {"x-secure": "user"}
  }
}