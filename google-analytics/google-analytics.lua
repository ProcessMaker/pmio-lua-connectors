--[[

# [Google Analytics API](https://developers.google.com/analytics/devguides/reporting/) connector.

### Authorization

Authorization use [Oauth authentication](https://developers.google.com/analytics/devguides/reporting/core/v3/reference).

## Input parameters

* `client_id` - application client_id.
* `client_secret` - client_secret
* `refresh_token`
* `api_endpoint` - api endpoint, e.g. calendars/example@gmail.com
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PATCH`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data, e.g.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.
Example connector output parameters:

```
{
  "kind": "analytics#accounts",
  "username": string,
  "totalResults": integer,
  "startIndex": integer,
  "itemsPerPage": integer,
  "previousLink": string,
  "nextLink": string,
  "items": [
    management.accounts Resource
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

-- utility method to make text URL friendly
function url_encode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end

local inputVar = cjson.decode(io.stdin:read("*a"))

local respbody = {}
local reqbody = inputVar.post_data and cjson.encode(inputVar.post_data) or ''

local refreshToken = inputVar.refresh_token
local clientId = inputVar.client_id
local clientSecret = inputVar.client_secret

local refreshTokenBody = "refresh_token=" .. url_encode(refreshToken) ..
  "&client_id=" .. url_encode(clientId) ..
  "&client_secret=" .. url_encode(clientSecret) ..
  "&grant_type=refresh_token"

r, c, h = https.request{
    method = 'POST',
    url = 'https://www.googleapis.com/oauth2/v4/token',
    headers = {

         ["Content-Type"] = "application/x-www-form-urlencoded",
         ["Content-Length"] = tostring(#refreshTokenBody)
    },
    source = ltn12.source.string(refreshTokenBody),
    sink = ltn12.sink.table(respbody)
}

local accessToken = cjson.decode(table.concat(respbody))["access_token"]

respbody = {}

local url = 'https://www.googleapis.com/' .. inputVar.api_endpoint


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