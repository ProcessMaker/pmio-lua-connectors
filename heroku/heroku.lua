--[[

# [Heroku Dev Center API](https://devcenter.heroku.com/articles/platform-api-reference) connector.

### Authorization

Authorization use [API Key](https://devcenter.heroku.com/articles/platform-api-quickstart).

## Input parameters

* access_token - your API Key.
* api_endpoint - API endpoint URI, e.g. `apps`.
* domain - e.g. `https://api.heroku.com/`
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "created_at":"2013-05-21T22:36:48-00:00",
  "id":"01234567-89ab-cdef-0123-456789abcdef",
  "git_url":"git@heroku.com:cryptic-ocean-8852.git",
  "name":"cryptic-ocean-8852",
  ...
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


local url = 'https://api.heroku.com/' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    method = method,
    url = url,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
         ["Accept"] = "application/vnd.heroku+json; version=3",
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