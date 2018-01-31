--[[

# [Zendesk Core API](https://developer.zendesk.com/rest_api/docs/core/introduction) connector.

### Authorization

Authorization use either [Basic authentication](https://developer.zendesk.com/rest_api/docs/core/introduction#basic-authentication) or [API token](https://developer.zendesk.com/rest_api/docs/core/introduction#api-token) authorization.

## Input parameters

* `email_address` - application user email used to authorize the call.

* `password` - user password used to authorize the call
* OR `api_token` - Basic authorization used to authorize private apps.
* OR `access_token` - OAuth authorization Token (NOT SUPPORTED IN THE CONNECTOR YET).

* zendesk_domain - your ZenDesk domain, e.g. `test-connector.zendesk.com`.
* api_endpoint - API endpoint URI, e.g. `api/v2/tickets/1.json`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data, e.g. `{"blog":{"title":"Test Title"}}` structure used to create a Blog item.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
ticket_subject = {response.ticket.subject}
ticket_description = {response.ticket.description}
```

* response - JSON decoded structure received from API response.
* code - HTTP response code.
* headers - headers structure received from API response.

]]--

local https = require("ssl.https")
local ltn12 = require"ltn12"
local cjson = require("cjson")

local mime = require("mime")



--URL encode a string.
local function encode(str)

  --Ensure all newlines are in CRLF form
  str = string.gsub (str, "\r?\n", "\r\n")

  --Percent-encode all non-unreserved characters
  --as per RFC 3986, Section 2.3
  --(except for space, which gets plus-encoded)
  str = string.gsub (str, "([^%w%-%.%_%~ ])",
    function (c) return string.format ("%%%02X", string.byte(c)) end)

  --Convert spaces to plus signs
  str = string.gsub (str, " ", "+")

  return str
end

local inputVar = cjson.decode(io.stdin:read("*a"))

local respbody = {}
local reqbody = inputVar.post_data and inputVar.post_data or ''

local url = 'https://' .. inputVar.zendesk_domain .. '/' .. inputVar.api_endpoint

if ( inputVar.email_address and inputVar.password) then user = inputVar.email_address password = inputVar.password end
if ( inputVar.email_address and inputVar.api_token) then user = inputVar.email_address .. '/token' password = inputVar.api_token end
    
local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{ 
    method = method,
    url = url,
    user = user,
    password = password,
    headers = {
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


