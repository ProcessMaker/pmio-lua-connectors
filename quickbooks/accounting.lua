--[[

# [QuickBooks Online API](https://developer.intuit.com/docs/00_quickbooks_online/5_api_reference/00_overview) connector.

### Authorization

Authorization use [Oauth 2.0 API access token](https://developer.intuit.com/docs/00_quickbooks_online/2_build/10_authentication_and_authorization/10_oauth_2.0).

## Input parameters

* access_token - application access token used to authorize installed app. Please note, QuickBook tokens are short-living and its your task to fetch/refresh active token, before you call the connector.

* quickbooks_domain - your quickbooks domain, e.g. sandbox-quickbooks.api.intuit.com.
* api_endpoint - API endpoint URI, e.g. `v3/company/123145991197879/invoice/145` to retrieve the Invoice with ID 145.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to POST/PUT data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
invoice_amount = {response.Invoice.TotalAmt}
invoice_currency_name = {response.Invoice.CurrencyRef.name}
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
local reqbody = inputVar.post_data and inputVar.post_data or ''

r, c,  h = https.request{ 
    method = inputVar.method and inputVar.method or 'GET',
    url = 'https://' .. inputVar.quickbooks_domain .. '/' .. inputVar.api_endpoint,
    headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["Content-Length"] = tostring(#reqbody),
        ["Authorization"] = 'Bearer ' .. inputVar.access_token
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
