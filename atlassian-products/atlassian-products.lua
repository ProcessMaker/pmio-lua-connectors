--[[

# [Atlassian products API](https://developer.atlassian.com/cloud/confluence/rest/) connector.

### Authorization

Authorization use [OAuth 2.0](https://developer.atlassian.com/cloud/confluence/rest/#auth).

## Input parameters

* api_token - API Token.
* api_endpoint - API endpoint URI, e.g. `/wiki/rest/api/user/current`.
* user - email.
* your_domain - e.g. `https://processmaker.atlassian.net`
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
      "description": {
        "plain": {
          "representation": "string",
          "value": "string"
        }
      },
      "key": "string",
      "name": "string",
      "permissions": [
        {
          "anonymousAccess": true,
          "operation": {},
          "subjects": {
            "_expandable": {
              "group": "string",
              "user": "string"
            },
            "group": {
              "results": [
                {
                  "_links": {},
                  "name": "string",
                  "type": "string"
                }
              ],
              "size": 123456
            },
            "user": {
              "results": [
                {
                  "_expandable": {
                    "details": "string",
                    "operations": "string"
                  },
                  "_links": {},
                  "accountId": "string",
                  "details": {
                    "business": {
                      "department": "string",
                      "location": "string",
                      "position": "string"
                    },
                    "personal": {
                      "email": "string",
                      "im": "string",
                      "phone": "string",
                      "website": "string"
                    }
                  },
                  "displayName": "string",
                  "operations": [
                    {
                      "operation": "string",
                      "targetType": "string"
                    }
                  ],
                  "profilePicture": {
                    "height": 123456,
                    "isDefault": true,
                    "path": "string",
                    "width": 123456
                  },
                  "type": "string",
                  "userKey": "string",
                  "username": "string"
                }
              ],
              "size": 123456
            }
          },
          "unlicensedAccess": true
        }
      ]
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

local apiToken = inputVar.api_token
local User = inputVar.user
local yourDomain = inputVar.your_domain

local url = yourDomain .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    user = User,
    password = apiToken,
    headers = {
         ["Accept"] = "application/json",
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


