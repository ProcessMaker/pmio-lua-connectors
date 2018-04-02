--[[
# [Watson API Explorer](https://console.bluemix.net/docs/services/personality-insights/getting-started.html#getting-started-tutorial) connector.

[Personality Insights](https://watson-api-explorer.mybluemix.net/apis/personality-insights-v3)

## Input parameters
* watson_domain - e.g. `https://watson-api-explorer.mybluemix.net/`.
* api_endpoint - API endpoint URI, e.g. `personality-insights/api/v3/profile`.
* text - A maximum of 20 MB of content to analyze, though the service requires much less text.

* method - optional request method, defauls to `POST`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters
All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.
Example connector output parameters:
```
{
  "processed_language": "ar",
  "word_count": 0,
  "word_count_message": "string",
  "personality": [
    {
      "trait_id": "string",
      "name": "string",
      "category": "personality",
      "percentile": 0,
      "raw_score": 0,
      "significant": true,
      "children": [
        {}
      ]
    }
  ],
  "values": [
    {
      "trait_id": "string",
      "name": "string",
      "category": "personality",
      "percentile": 0,
      "raw_score": 0,
      "significant": true,
      "children": [
        {}
      ]
    }
  ],
  "needs": [
    {
      "trait_id": "string",
      "name": "string",
      "category": "personality",
      "percentile": 0,
      "raw_score": 0,
      "significant": true,
      "children": [
        {}
      ]
    }
  ],
  "behavior": [
    {
      "trait_id": "string",
      "name": "string",
      "category": "string",
      "percentage": 0
    }
  ],
  "consumption_preferences": [
    {
      "consumption_preference_category_id": "string",
      "name": "string",
      "consumption_preferences": [
        {
          "consumption_preference_id": "string",
          "name": "string",
          "score": "0.0"
        }
      ]
    }
  ],
  "warnings": [
    {
      "warning_id": "WORD_COUNT_MESSAGE",
      "message": "string"
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
local reqbody = inputVar.text or ''

local watson_domain = inputVar.watson_domain or 'https://watson-api-explorer.mybluemix.net/'

local user = inputVar.username
local password = inputVar.password
local version = inputVar.version

local url = watson_domain .. inputVar.api_endpoint .. '?version=' .. url_encode(version)

local method = inputVar.method and inputVar.method or 'POST'

r, c,  h = https.request{
    url = url,
    method = method,
    user = user,
    password = password,
    headers = {
         ["Content-Type"] = "text/plain",
         ["Accept"] = "application/json",
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