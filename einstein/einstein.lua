--[[

# [Salesforce Einstein Vision](https://metamind.readme.io/v2/docs) connector.

### Authorization

Authorization use [OAuth Authentication](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_web_server_oauth_flow.htm).

### Requirements

  * luarocks install multipart-post


## Input parameters

* 'access_token' - Bearer access token.
* api_endpoint - API endpoint URI, e.g. `v2/vision/predict`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "probabilities": [
    {
      "label": "beach",
      "probability": 0.9602110385894775
    },
    {
      "label": "mountain",
      "probability": 0.039788953959941864
    }
  ],
  "object": "predictresponse"
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

local enc = (require "multipart-post").encode

local inputVar = cjson.decode(io.stdin:read("*a"))

local respbody = {}
local reqbody = inputVar.post_data and cjson.encode(inputVar.post_data) or ''

local accessToken = inputVar.access_token

local url = 'https://api.einstein.ai/' .. inputVar.api_endpoint


local method = inputVar.method and inputVar.method or 'POST'

local body, boundary = enc{
  sampleLocation=inputVar.post_data.sampleLocation,
  modelId=inputVar.post_data.modelId
}

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
         ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
         ["Content-Length"] = tostring(#body)
    },
    source = ltn12.source.string(body),
    sink = ltn12.sink.table(respbody)
}

-- printing result output data as JSON
print(cjson.encode({
    response = cjson.decode(table.concat(respbody)),
    code = c,
    headers = h
}))
