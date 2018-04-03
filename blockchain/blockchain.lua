--[[

# [Blockchain API](https://blockchain.info/api/api_receive) connector.

### Authorization

Authorization use [API key](https://api.blockchain.info/customer/signup)

## Input parameters

* api_endpoint -API endpoint URI, e.g. 'boards/id'.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.
```
 "post_data": {
    "key": [your_key],
    "callback": [your_callback_url],
    "addr": [your_address],
    "op" : "RECEIVE",
    "confs" : 5,
    "onNotification" : "KEEP"
  }
```
## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "id" : 660447,
  "addr" : "1Le8xUDSGkXxKNkb1nbSP4PrRoMZnWbu5t",
  "op" : "RECEIVE",
  "confs" : 5,
  "callback" : "https://mystore.com?invoice_id=123",
  "onNotification" : "KEEP"
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

local url = 'https://api.blockchain.info/v2/receive/' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'POST'

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
         ["Content-Type"] = "text/plain",
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

