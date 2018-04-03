--[[
# [Watson API Explorer](https://console.bluemix.net/docs/services/natural-language-understanding/getting-started.html#getting-started-tutorial) connector.

[Natural Language Understanding](https://watson-api-explorer.mybluemix.net/apis/natural-language-understanding-v1)

## Input parameters
* watson_domain - e.g. `https://watson-api-explorer.mybluemix.net/natural-language-understanding/api`.
* api_endpoint - API endpoint URI, e.g. `/v1/analyze`.
* user - username.
* password - your password
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.
* params - e.g.
```
"params": {
    "version":"2017-02-27",
    "text":"hello",
    "features":"entities",
    "return_analyzed_text":"false",
    "clean":"true",
    "fallback_to_raw":"true",
    "language":"en",
    "concepts.limit":"8",
    "emotion.document":"true",
    "entities.limit":"50",
    "entities.mentions":"false",
    "entities.emotion":"false",
    "entities.sentiment":"false",
    "keywords.limit":"50",
    "keywords.emotion":"false",
    "keywords.sentiment":"false",
    "relations.model":"en-news",
    "semantic_roles.limit":"50",
    "semantic_roles.entities":"false",
    "semantic_roles.keywords":"false",
    "sentiment.document":"true"
  }
```

## Output parameters
All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:
```
{
  "usage": {
    "text_units": 1,
    "text_characters": 5,
    "features": 1
  },
  "language": "en",
  "entities": []
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

local watson_domain = inputVar.watson_domain

local user = inputVar.username
local password = inputVar.password

local url = watson_domain .. inputVar.api_endpoint .. '?'

for key,value in pairs(inputVar.params) do
  url = url .. key .. '=' .. url_encode(value) .. '&'
end

url = url:sub(1, -2)

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    user = user,
    password = password,
    headers = {
         ["Accept"] = "application/json",
    },
    sink = ltn12.sink.table(respbody)
}
-- printing result output data as JSON
print(cjson.encode({
    response = cjson.decode(table.concat(respbody)),
    code = c,
    headers = h
}))
