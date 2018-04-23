--[[
# [LinkedIn API](https://developer.linkedin.com/docs/rest-api) connector.

### Authorization

Authorization use [OAuth 2.0](https://developer.linkedin.com/docs/oauth2).

## Input parameters

* access_token - Access token.
* api_endpoint - API endpoint URI, e.g. `v1/people/`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.
Example connector output parameters:
```
{
  "firstName": "Svitlana",
  "headline": "ProcessMaker",
  "id": "ui-lDJ-ZNw",
  "lastName": "lastname",
  "siteStandardProfileRequest": {"url": "https://www.linkedin.com/profile/view?id=AAoAACRQxXIBFa2An7hF4KpJH0jzI4VGxGQc2k4&authType=name&authToken=C6i8&trk=api*a3227641*s3301901*"}
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

local url = 'https://api.linkedin.com/' .. inputVar.api_endpoint .. '~?oauth2_access_token=' .. accessToken .. '&format=json'

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
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