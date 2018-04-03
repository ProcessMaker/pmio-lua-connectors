--[[

# [Trello API](https://developers.trello.com/v1.0/reference) connector.

### Authorization

Authorization use [OAuth 2.0](https://developers.trello.com/v1.0/reference#authorization.)

## Input parameters

* token - Trello Token.
* api_key - API Key.
* api_endpoint -API endpoint URI, e.g. 'boards/id'.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "id":"59523d5e4a3620054949ba8f",
  "name":"PMIO",
  "desc":"",
  "descData":null,
  "closed":false,
  "idOrganization":null,
  "pinned":false,
  "url":"https://trello.com/b/7pZ02eod/pmio",
  "shortUrl":"https://trello.com/b/7pZ02eod",
  "prefs":
    {
      "permissionLevel":"private",
      "voting":"disabled",
      "comments":"members",
      "invitations":"members",
      "selfJoin":false,
      "cardCovers":true,
      "cardAging":"regular",
      "calendarFeedEnabled":false,
      "background":"blue",
      "backgroundImage":null,
      "backgroundImageScaled":null,
      "backgroundTile":false,
      "backgroundBrightness":"dark",
      "backgroundColor":"#0079BF",
      "backgroundBottomColor":"#0079BF",
      "backgroundTopColor":"#0079BF",
      "canBePublic":true,
      "canBeOrg":true,
      "canBePrivate":true,
      "canInvite":true
    },
  "labelNames":
    {
      "green":"",
      "yellow":"",
      "orange":"",
      "red":"",
      "purple":"",
      "blue":"",
      "sky":"",
      "lime":"",
      "pink":"",
      "black":""
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

local inputVar = cjson.decode(io.stdin:read("*a"))

local respbody = {}
local reqbody = inputVar.post_data and cjson.encode(inputVar.post_data) or ''

local token = inputVar.token
local apiKey = inputVar.api_key

local url = 'https://api.trello.com/1/' .. inputVar.api_endpoint .. '?key=' .. apiKey .. '&token=' .. token

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
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


