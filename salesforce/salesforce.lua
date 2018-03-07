--[[

# [Salesfors API](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/) connector.

### Authorization

Authorization use [OAuth Authentication](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/intro_understanding_web_server_oauth_flow.htm).


## Input parameters

* 'access_token' - Bearer access token.
* api_endpoint - API endpoint URI, e.g. `services/data/v39.0/sobjects/Domain`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "objectDescribe": {
    "activateable": false,
    "createable": false,
    "custom": false,
    "customSetting": false,
    "deletable": false,
    "deprecatedAndHidden": false,
    "feedEnabled": false,
    "hasSubtypes": false,
    "isSubtype": false,
    "keyPrefix": "0I4",
    "label": "Domain",
    "labelPlural": "Domains",
    "layoutable": false,
    "mergeable": false,
    "mruEnabled": false,
    "name": "Domain",
    "queryable": true,
    "replicateable": false,
    "retrieveable": true,
    "searchable": false,
    "triggerable": false,
    "undeletable": false,
    "updateable": false,
    "urls": {
      "rowTemplate": "/services/data/v39.0/sobjects/Domain/{ID}",
      "defaultValues": "/services/data/v39.0/sobjects/Domain/defaultValues?recordTypeId&fields",
      "describe": "/services/data/v39.0/sobjects/Domain/describe",
      "sobject": "/services/data/v39.0/sobjects/Domain"
    }
  },
  "recentItems": []
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

local url = inputVar.instance_url .. inputVar.api_endpoint

local accessToken = inputVar.access_token

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
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


