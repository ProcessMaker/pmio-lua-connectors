--[[
# [DocuSign API](https://docs.docusign.com/esign/guide/usage/quickstart.html) connector.

### Authentication

Authentication use [Authentication](https://docs.docusign.com/esign/guide/authentication/legacy_auth.html).

## Input parameters

* `username` - application user email used to authorize the call.
* `password` - user password used to authorize the call
* `integratorKey` - integration and authenticate with the DocuSign platform

* `baseUrl` - https://demo.docusign.net/restapi/v2/
* api_endpoint - API endpoint URI.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data, e.g.
  ```
    {
    "documents":
      {
        "documentBase64": "FILE1_BASE64",
        "documentId": "1",
        "fileExtension": "pdf",
        "name": "NDA.pdf"
      }
    }
  ```

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
name = {response.name}
accountId = {response.accountId}
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

local url = inputVar.baseUrl .. inputVar.api_endpoint

local user = inputVar.username
local password = inputVar.password
local integratorKey = inputVar.integratorKey

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    method = method,
    url = url,
    headers = {
         ["X-DocuSign-Authentication"] = cjson.encode({
          ["Username"] = user,
          ["Password"] = password,
          ["IntegratorKey"] = integratorKey
         }),
         ["Content-Type"] = "application/json",
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


