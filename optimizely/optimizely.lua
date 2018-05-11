--[[

# [Optimizely API](https://developers.optimizely.com/x/rest/introduction/) connector.

### Authorization

Authorization use [OAuth 2.0](https://developers.optimizely.com/x/authentication/oauth/#authorization).

## Input parameters

* access_tokent - your Access Token.
* api_endpoint - API endpoint URI, e.g. `v1/me`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "id": 859720118,
  "account_id": 555650815,
  "code_revision": 12,
  "project_name": "My even newer project name",
  "project_status": "Active",
  "created": "2014-04-16T21:33:34.408430Z",
  "last_modified": "2014-06-10T22:12:21.707170Z",
  "library": "jquery-1.6.4-trim",
  "include_jquery": false,
  "js_file_size": 23693,
  "project_javascript": "someFunction = function () {\n //Do cool reusable stuff \n}"
  "enable_force_variation": false,
  "exclude_disabled_experiments": false,
  "exclude_names": null,
  "ip_anonymization": false,
  "ip_filter": "1.2.3.4",
  "socket_token": "AABBCCDD~123456789",
  "dcp_service_id": 121234
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


local url = 'https://api.optimizely.com/' .. inputVar.api_endpoint

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