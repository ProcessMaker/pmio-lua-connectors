--[[

# [TWILIO MESSAGING API](https://www.twilio.com/docs/api/messaging) connector.

### Authorization

Authorization use [Basic authentication]( https://www.twilio.com/docs/api/messaging#messaging-api-authentication).

## Input parameters

* `to` - Phone Number.
* `from` - your Twilio Phone Number.
* `body` - text your message.
* `auth_token` -
* `api_endpoint` - API endpoint URI, e.g. `/Messages.json`.
* method - optional request method, defauls to `POST`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "sid": "SM54b0909d694040e8a6785b89f6b01dba",
  "date_created": "Mon, 19 Mar 2018 11:34:23 +0000",
  "date_updated": "Mon, 19 Mar 2018 11:34:23 +0000",
  "date_sent": null,
  "account_sid": "AC495a49165d00a53ce0ced108764949d9",
  "to": "+380669338008",
  "from": "+18643513762",
  "messaging_service_sid": null,
  "body": "Sent from your Twilio trial account - Hello my friend",
  "status": "queued",
  "num_segments": "1",
  "num_media": "0",
  "direction": "outbound-api",
  "api_version": "2010-04-01",
  "price": null,
  "price_unit": "USD",
  "error_code": null,
  "error_message": null,
  "uri": "/2010-04-01/Accounts/AC495a49165d00a53ce0ced108764949d9/Messages/SM54b0909d694040e8a6785b89f6b01dba.json",
  "subresource_uris": {
      "media": "/2010-04-01/Accounts/AC495a49165d00a53ce0ced108764949d9/Messages/SM54b0909d694040e8a6785b89f6b01dba/Media.json"
  }
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

local accountSid = inputVar.account_sid
local apiEndpoint = inputVar.api_endpoint
local authToken = inputVar.auth_token
local to = inputVar.to
local from = inputVar.from
local body = inputVar.body

local postData = 'To=' .. url_encode(to) .. '&From=' .. url_encode(from) .. '&Body=' .. url_encode(body)

local url = 'https://api.twilio.com/2010-04-01/Accounts/' .. accountSid .. '/' .. apiEndpoint


local method = inputVar.method and inputVar.method or 'POST'

r, c,  h = https.request{
    url = url,
    method = method,
    user = accountSid,
    password = authToken,
    headers = {
         ["Content-Type"] = "application/x-www-form-urlencoded",
         ["Accept"] = "application/json",
         ["Content-Length"] = tostring(#postData)
    },
    source = ltn12.source.string(postData),
    sink = ltn12.sink.table(respbody)
}

-- printing result output data as JSON
print(cjson.encode({
    response = cjson.decode(table.concat(respbody)),
    code = c,
    headers = h
}))


