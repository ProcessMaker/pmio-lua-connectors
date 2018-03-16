--[[

# [Watson API Explorer](https://console.bluemix.net/docs/services/language-translator/getting-started.html) connector.


[Speech to Text](https://watson-api-explorer.mybluemix.net/apis/speech-to-text-v1)


## Input parameters

* watson_domain - e.g. `https://watson-api-explorer.mybluemix.net/speech-to-text/api/`.
* api_endpoint - API endpoint URI, e.g. `v1/models/`.
* model_id - The identifier of the desired model in the form of its name from the output of GET /v1/models. e.g. `ar-AR_BroadbandModel`
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "translations": [
    {
      "translation": "Modell-ID der Übersetzung verwendet werden soll. Wenn dieser Parameter angegeben ist, die Quelle und das Ziel wird ignoriert. Die Methode muss entweder eine Modell-ID oder beide Parameter die Quelle und das Ziel."
    }
  ],
  "word_count": 38,
  "character_count": 193
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
local model_id = inputVar.model_id

local watson_domain = inputVar.watson_domain or 'https://watson-api-explorer.mybluemix.net/speech-to-text/api/'

local url = watson_domain .. inputVar.api_endpoint .. inputVar.model_id

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
         ["Content-Type"] = "application/json",
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


