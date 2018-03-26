--[[

# [Watson API Explorer](https://console.bluemix.net/docs/services/language-translator/getting-started.html) connector.


[Language Translator](https://watson-api-explorer.mybluemix.net/apis/language-translator-v2)


## Input parameters

* watson_domain - e.g. `https://watson-api-explorer.mybluemix.net/language-translator/api/`.
* api_endpoint - API endpoint URI, e.g. `/v2/translate`.
* text - Input text in UTF-8 encoding. Multiple text entries will result in multiple translations in the response.
* source - Language code of the source text language. e.g. `en`
* target - Language code of the translation target language. Use with source as an alternative way to select a translation model. e.g. `de`
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
local text = inputVar.text
local source = inputVar.source
local target = inputVar.target

local watson_domain = inputVar.watson_domain or 'https://watson-api-explorer.mybluemix.net/language-translator/api/'

local url = watson_domain .. inputVar.api_endpoint .. '?text=' .. url_encode(text) .. '&source=' .. source .. '&target=' .. target

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


