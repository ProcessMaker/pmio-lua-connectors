--[[

# [Moxtra API](https://developer.moxtra.com/docs/docs-rest-api) connector.

### Authorization

Authorization use [OAuth 2.0](https://developer.moxtra.com/docs/docs-oauth/).

## Input parameters

* access_tokent - your Access Token.
* api_endpoint - API endpoint URI, e.g. `v1/me`.
* domain - e.g. `https://apisandbox.moxtra.com/`
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
    "code": "RESPONSE_SUCCESS",
    "data": {
        "id": "UiaduESWsbzFoK9TOldC6zF",
        "email": "jim@test.com",
        "name": "jim test",
        "first_name": "jim",
        "last_name": "test",
        "unique_id": "",
        "picture_uri": "https://www.moxtra.com/user/2342",
        "type": "USER_TYPE_NORMAL",
        "timezone": "America/Los_Angeles",
        "language": "en",
        "org_id": "PuE0cDUJRkg98FG0FUwJqi4",
        "org_plan_code": "prouser",
        "org_status": "GROUP_NORMAL_SUBSCRIPTION",
        "teams": [
            {
                "id": "PRTA3fRhzcxEPit77Dw063F",
                "name": "John's team",
                "created_time": 1467327047209,
                "updated_time": 1468541973985
            }
        ]
        "created_time": 1348864985783,
        "updated_time": 1348864985783
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

local accessToken = inputVar.access_token


local url = 'https://api.optimizely.com/' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    method = method,
    url = url,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
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