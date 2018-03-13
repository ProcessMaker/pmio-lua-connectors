--[[

# [Box](https://developer.box.com/docs) connector.

### Authorization

Authorization use [Authentication with OAuth](https://developer.box.com/docs/oauth-20).

## Input parameters

* access_token - access token for your application
* api_endpoint - API endpoint URI.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.
## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
    "total_count":0,
    "entries":[],
    "offset":0,
    "limit":100,
    "order":[
        {"by":"type",
        "direction":"ASC"},
        {"by":"name",
        "direction":"ASC"}
    ]
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

local url = 'https://api.box.com/2.0/' .. inputVar.api_endpoint

local accessToken = inputVar.access_token

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
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


