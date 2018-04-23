--[[
# [Watson Text to Speech API Explorer](https://console.bluemix.net/docs/services/text-to-speech/getting-started.html#gettingStarted) connector.

[Text to Speech](https://watson-api-explorer.mybluemix.net/apis/text-to-speech-v1)

## Additional requirements

  * (lbase64)[https://luarocks.org/modules/luarocks/lbase64]

  ```
  luarocks install lbase64
  ```

## Input parameters
* watson_domain - e.g. `https://watson-api-explorer.mybluemix.net/text-to-speech/api/`.
* api_endpoint - API endpoint URI, e.g. `v/v1/synthesize`.
* voice - The voice to use for synthesis. e.g. `en-US_LisaVoice`
* text - The text to synthesize. Use either plain text or a subset of SSML. Text size is limited to 5 KB. e.g. `Hello from Processmaker IO`.
* accept - The requested audio format (MIME type) of the audio. You can use this query parameter or the Accept header to specify the audio format. (For the audio/l16 format, you can optionally specify endianness=big-endian or endianness=little-endian; the default is little endian.) e.g. `audio/mp3`.
* user - username.
* password - your password
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters
All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:
```
{
  "code":200,
  "output":_here_will_be_base64_encoded_content_,
  "headers":{ ... }
}
```
* response - JSON decoded structure received from API response.
* code - HTTP response code.
* headers - headers structure received from API response.
]]--

local https = require("ssl.https")
local ltn12 = require"ltn12"
local cjson = require("cjson")
local base64 = require("base64")

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

local watson_domain = inputVar.watson_domain

local user = inputVar.user
local password = inputVar.password
local accept = inputVar.accept
local voice = inputVar.voice or 'en-US_LisaVoice'
local text = inputVar.text

local url = watson_domain .. inputVar.api_endpoint .. '?accept=' .. url_encode(accept) .. '&text=' .. url_encode(text) .. '&voice=' .. url_encode(voice)

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    user = user,
    password = password,
    headers = {
         ["Accept"] = "audio/mpeg",
         ["Content-Length"] = tostring(#reqbody)
    },
    source = ltn12.source.string(reqbody),
    sink = ltn12.sink.table(respbody)
}

-- printing result output data as JSON
if c == 200 then
  print(cjson.encode({
    code = c,
    headers = h,
    output = base64.encode(table.concat(respbody))
  }))
else
  print(cjson.encode({
      response = cjson.decode(table.concat(respbody)),
      code = c,
      headers = h
  }))
end
