--[[

Shopify Admin API connector @link https://help.shopify.com/api/reference/shop

### Authorization

Authorization use either API access token or API key-password pair.

## Input parameters

* access_token - application access token used to authorize installed app.
* api_key, api_password - Basic authorization used to authorize private apps.

* store_domain - your shop domain, e.g. hlorofos-test-store.myshopify.com.
* api_endpoint - Admin API endpoint URI, e.g. `shop.json`, `blogs/4916117540.json`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data, e.g. `{"blog":{"title":"Test Title"}}` structure used to create a Blog item.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
shop_name = {response.shop.name}
shop_url = {response.shop.myshopify_domain}
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

local url = 'https://'
if ( inputVar.api_key and inputVar.api_password) then url = url .. inputVar.api_key .. ':' .. inputVar.api_password .. '@' end
url = url .. inputVar.store_domain .. '/admin/' .. inputVar.api_endpoint

if ( inputVar.access_token ) then url = url .. '?access_token=' .. inputVar.access_token end

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{ 
    method = method,
    url = url,
    headers = {
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
