--[[

# [Asana API](https://asana.com/developers/api-reference/) connector.

### Authorization

Authorization use [Access Token](https://asana.com/guide/help/api/api).

## Input parameters

* access_tokent - your  Personal Access Token.
* api_endpoint - API endpoint URI, e.g. `api/1.0/users/me`.
* domain - e.g. `https://app.asana.com/`
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "data": {
    "workspaces": [
      {
        "id": 1337,
        "name": "My Favorite Workspace"
      },
      "~..."
    ],
    "id": 5678,
    "name": "Greg Sanchez",
    "email": "gsanchez@example.com"
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

local accessToken = inputVar.access_token


local url = 'https://app.asana.com/' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    method = method,
    url = url,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
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