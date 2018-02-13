--[[

# [Google Calendar API](https://developers.google.com/google-apps/calendar/v3/reference/) connector.

### Authorization

Authorization use [Basic authentication](console.developers.google.com).

## Input parameters

* `client_id` - application client_secret.
* `client_secret` - client_secret
* `refresh_token`
* `calendarId` - Id of the calendar (email)

* api_endpoint - API endpoint URI, e.g. `user`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data, e.g. `{"blog":{"title":"Test Title"}}` structure used to create a Blog item.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
id = {response.id}
summary = {response.summary}
timeZone = {respons.timeZone}
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
  -- TODO add Authorization header if access_token provided
    },
    source = ltn12.source.string(refreshTokenBody),
    sink = ltn12.sink.table(respbody)
}

local accessToken = cjson.decode(table.concat(respbody))["access_token"]

respbody = {}

local url = 'https://www.googleapis.com/calendar/v3/calendars/' .. inputVar.calendarId


local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    method = method,
    url = url,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
         ["Content-Type"] = "application/json",
         ["Content-Length"] = tostring(#reqbody)
  -- TODO add Authorization header if access_token provided
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
