--[[

# [New Relic API](https://docs.newrelic.com/docs/apis/getting-started/intro-apis/introduction-new-relic-apis) connector.

### Authorization

Authorization use [API key](https://docs.newrelic.com/docs/apis/rest-api-v2/getting-started/access-rest-api-keys).

## Input parameters

* `api_key` - your API Key.
* api_endpoint - API endpoint URI, e.g. `api/v1/nudges/SURVEY_ID/responses.json`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "users": [
    {
      "id": 2186836,
      "first_name": "Svitlana",
      "last_name": "Kh",
      "email": "name@processmaker.com",
      "role": "owner"
    }
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

local apiKey = inputVar.api_key

local url = 'https://api.newrelic.com/' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    method = method,
    url = url,
    headers = {
         ["X-Api-Key"] = apiKey,
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