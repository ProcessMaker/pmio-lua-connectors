--[[

# [Dropbox Business API](https://www.dropbox.com/developers/documentation) connector.

### Authorization

Authorization use [Basic authentication](https://www.dropbox.com/developers/documentation/http/documentation#oauth2-authorize).

## Input parameters

* 'api_key' - application user email used to authorize the call.
* api_endpoint - API endpoint URI, e.g. `user`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data, e.g. `{"blog":{"title":"Test Title"}}` structure used to create a Blog item.

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

local url = 'https://api.dropboxapi.com/2' .. '/' .. inputVar.api_endpoint

local apiKey = inputVar.api_key

local method = inputVar.method and inputVar.method or 'POST'

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
         ["Authorization"] = "Bearer " .. apiKey,
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


