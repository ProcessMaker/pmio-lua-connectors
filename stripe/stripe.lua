--[[

# [Stripe API](https://stripe.com/docs/api) connector.

### Authorization

Authorization use [API key](https://stripe.com/docs/dashboard#api-keys).

## Input parameters

* `secret_key` - stripe secret key.

* api_endpoint - API endpoint URI, e.g. `balance`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "pending":
    [{
      "amount":0,
      "currency":"usd",
      "source_types":{"card":0}
    }],
  "object":"balance",
  "available":
    [{
      "amount":0,
      "currency":"usd",
      "source_types":{"card":0}
    }],
  "livemode":false
}
```

* response - JSON decoded structure received from API response.
* code - HTTP response code.
* headers - headers structure received from API response.

]]--

local https = require("ssl.https")
local ltn12 = require"ltn12"
local cjson = require("cjson")

local mime = require("mime")

local inputVar = cjson.decode(io.stdin:read("*a"))

local respbody = {}
local reqbody = inputVar.post_data and cjson.encode(inputVar.post_data) or ''

local url = 'https://api.stripe.com/v1/' .. inputVar.api_endpoint

local token = inputVar.secret_key

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    method = method,
    url = url,
    headers = {
         ["Authorization"] = "Bearer " .. token,
         ["Content-Type"] = "application/json",
         ["Content-Length"] = tostring(#reqbody)
    },
    source = ltn12.source.string(reqbody),
    sink = ltn12.sink.table(respbody)
}

-- printing result output data as JSON
print(cjson.encode({
    response = cjson.decode(table.concat(respbody)),
    code = c,
    headers = h
}))


