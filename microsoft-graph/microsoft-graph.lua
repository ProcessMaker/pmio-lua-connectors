--[[

# [Microsoft Graph API](https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/api) connector.

### Authorization

Authorization use [Basic authentication](https://developer.microsoft.com/en-us/graph/docs/concepts/auth_overview).

"expires_in": 3600

## Input parameters

* 'access_token' - Bearer access token.
* api_endpoint - API endpoint URI, e.g. `user`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
name = {response.Public}
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

local url = 'https://graph.microsoft.com/' .. inputVar.api_endpoint

local accessToken = inputVar.access_token

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
         ["Content-Type"] = "application/json",
         ["Content-Length"] = tostring(#reqbody)
  -- TODO add Authorization header if access_token provided
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


