--[[

# [FreshBooks API](https://www.freshbooks.com/api) connector.

### Authorization

Authorization use [OAuth2 authentication](https://www.freshbooks.com/api/authentication).

## Input parameters

* 'access_token' - Bearer access token.
* api_endpoint - API endpoint URI, e.g. `accounting/account/<accountid>/users/clients`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "response": {
    "result": {
      "per_page": 15,
      "total": 1,
      "page": 1,
      "clients": [
        {
          "allow_late_notifications": true,
          "fax": "",
          "last_activity": null,
          "num_logins": 0,
          "vat_number": "",
          "pref_email": true,
          "id": 78583,
          "direct_link_token": null,
          "s_province": "",
          "note": null,
          "s_city": "",
          "s_street2": "",
          "statement_token": null,
          "lname": "Sh",
          "mob_phone": "",
          "last_login": null,
          "fname": "Svitulia",
          "role": "client",
          "company_industry": null,
          "subdomain": null,
          "email": "",
          "username": "svituliash",
          "updated": "2018-03-20 09:43:37",
          "home_phone": null,
          "vat_name": null,
          "p_city": "",
          "bus_phone": "",
          "allow_late_fees": true,
          "s_street": "",
          "p_street": "",
          "company_size": null,
          "accounting_systemid": "p8GNN",
          "p_code": "",
          "p_province": "",
          "signup_date": "2018-03-20 13:41:44",
          "language": "en",
          "level": 0,
          "notified": false,
          "userid": 78583,
          "p_street2": "",
          "pref_gmail": false,
          "vis_state": 0,
          "s_country": "",
          "s_code": "",
          "organization": "Yes",
          "p_country": "Ukraine",
          "currency_code": "UAH"
        }
      ],
      "pages": 1
    }
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

local url = 'https://api.freshbooks.com/' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    headers = {
         ["Authorization"] = "Bearer " .. accessToken,
         ["Content-Type"] = "application/json",
         ["Api-Version"] = "alpha",
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


