--[[

# [Intercom API](https://developers.intercom.com) connector.

### Authorization

Authorization use [Basic authentication](https://developers.intercom.com/v2.0/reference#personal-access-tokens-1).


## Input parameters

* 'access_token' - Bearer access token.
* api_endpoint - API endpoint URI, e.g. `events?type=user&email=`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "event_name" : "placed-order",
  "created_at": 1389913941,
  "user_id": "314159",
  "metadata": {
    "order_date": 1392036272,
    "stripe_invoice": "inv_3434343434",
    "order_number": {
      "value":"3434-3434",
      "url": "https://example.org/orders/3434-3434"
    },
    "price": {
      "currency":"usd",
      "amount": 2999
    }
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

local url = 'https://api.intercom.io/' .. inputVar.api_endpoint

local accessToken = inputVar.access_token

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
         ["Content-Type"] = "application/json",
         ["Accept"] = "application/json",
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


