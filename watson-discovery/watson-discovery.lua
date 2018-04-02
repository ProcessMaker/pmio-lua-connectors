--[[
# [Watson API Explorer]https://console.bluemix.net/docs/services/discovery/getting-started-tool.html#getting-started-with-the-tooling) connector.

[Discovery](https://watson-api-explorer.mybluemix.net/apis/discovery-v1#!/Configurations/listConfigurations)

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
  "environments": [
    {
      "environment_id": "ecbda78e-fb06-40b1-a43f-a039fac0adc6",
      "name": "byod_environment",
      "description": "Private Data Environment",
      "created": "2017-07-14T12:54:40.985Z",
      "updated": "2017-07-14T12:54:40.985Z",
      "read_only": false
    },
    {
      "environment_id": "system",
      "name": "Watson System Environment",
      "description": "Watson System environment",
      "created": "2017-07-13T01:14:20.761Z",
      "updated": "2017-07-13T01:14:20.761Z",
      "read_only": true
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
local reqbody = inputVar.post_data and cjson.encode(inputVar.post_data) or ''

local watson_domain = inputVar.watson_domain or 'https://watson-api-explorer.mybluemix.net/'

local user = inputVar.username
local password = inputVar.password
local version = inputVar.version

local url = watson_domain .. inputVar.api_endpoint .. '?version=' .. url_encode(version)

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    user = user,
    password = password,
    headers = {
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