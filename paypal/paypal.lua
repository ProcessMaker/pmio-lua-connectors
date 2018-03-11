--[[

# [PayPal API](https://developer.paypal.com/docs/api/overview/) connector.

### Authorization

Authorization use [OAuth 2.0](https://developer.paypal.com/docs/api/overview/#authentication-and-authorization).

## Input parameters

* `client_id` - paypal client ID

* `secret` - paypal secret.
* `grant_type` - client_credentials.

* api_endpoint - API endpoint URI, e.g. `payment`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "payments":
    {
      "id": "PAY-0US81985GW1191216KOY7OXA",
      "create_time": "2017-06-30T23:48:44Z",
      "update_time": "2017-06-30T23:49:27Z",
      "state": "approved",
      "intent": "order",
      "payer": {
        "payment_method": "paypal"
    }
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

local paypalDomain = inputVar.paypal_domain
local clientId = inputVar.client_id
local clientSecret = inputVar.client_secret

r, c, h = https.request{
    method = 'POST',
    url = paypalDomain .. '/v1/oauth2/token',
    user = clientId,
    password = clientSecret,
    headers = {
         ["Accept"] = "application/json",
         ["Content-Length"] = tostring(#"grant_type=client_credentials")
    },
    source = ltn12.source.string("grant_type=client_credentials"),
    sink = ltn12.sink.table(respbody)
}

local accessToken = cjson.decode(table.concat(respbody))["access_token"]
respbody = {}

url =  paypalUrl .. '/' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    method = method,
    url = url,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
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


