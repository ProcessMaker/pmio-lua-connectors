--[[

# [Bitbucket API](https://developer.atlassian.com/bitbucket/api/2/reference/) connector.

### Authorization

Authorization use [OAuth 2.0](https://developer.atlassian.com/cloud/bitbucket/oauth-2/).

## Input parameters

* app_password - your app password.
* api_endpoint - API endpoint URI, e.g. `/2.0/repositories`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "updated_on": "2013-11-08T01:11:03.263237+00:00",
  "size": 33348,
  "is_private": false,
  "uuid": "{21fa9bf8-b5b2-4891-97ed-d590bad0f871}"
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

local appPassword = inputVar.app_password
local User = inputVar.username

local url = 'https://api.bitbucket.org' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    user = User,
    password = appPassword,
    headers = {
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


