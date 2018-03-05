--[[

# [Sendgrid API v3](https://sendgrid.com/docs/API_Reference/api_v3.html) connector.

### Authorization

Authorization use [Sendgrid API Keys](https://sendgrid.com/docs/API_Reference/Web_API_v3/API_Keys/index.html).

## Input parameters

* api_key - your sendgrid API key.
* api_endpoint - API endpoint URI, e.g. `v3/mail/send`
* method - optional request method, defaults to `POST`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to POST/PUT data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "personalizations": [
    {
      "to": [
        {
          "email": "john.doe@example.com",
          "name": "John Doe"
        }
      ],
      "subject": "Hello, World!"
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

local inputVar = cjson.decode(io.stdin:read("*a"))

local respbody = {}
local reqbody = inputVar.post_data and cjson.encode(inputVar.post_data) or ''

local apiKey = inputVar.api_key

r, c,  h = https.request{
    method = inputVar.method and inputVar.method or 'POST',
    url = 'https://api.sendgrid.com/' .. inputVar.api_endpoint,
    headers = {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = tostring(#reqbody),
        ["Authorization"] = 'Bearer ' .. apiKey
    },
    source = ltn12.source.string(reqbody),
    sink = ltn12.sink.table(respbody)
}

-- printing result output data as JSON
if (c == 202) then
    print(cjson.encode({
        code = c,
        headers = h
    }))
else
    print(cjson.encode({
        response = cjson.decode(table.concat(respbody)),
        code = c,
        headers = h
    }))
end
