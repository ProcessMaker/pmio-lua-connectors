--[[

# [Digital Ocean API](https://developers.digitalocean.com/documentation/v2/) connector.

### Authorization

Authorization use [OAuth](https://developers.digitalocean.com/documentation/v2/#authentication).

## Input parameters

* access_token - Access token.
* api_endpoint - API endpoint URI, e.g. `v2/droplets`.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "droplets": [
    {
      "id": 3164444,
      "name": "example.com",
      "memory": 1024,
      "vcpus": 1,
      "disk": 25,
      "locked": false,
      "status": "active",
      "kernel": {
        "id": 2233,
        "name": "Ubuntu 14.04 x64 vmlinuz-3.13.0-37-generic",
        "version": "3.13.0-37-generic"
      },
      "created_at": "2014-11-14T16:29:21Z",
      "features": [
        "backups",
        "ipv6",
        "virtio"
      ],
      "backup_ids": [
        7938002
      ],
      "snapshot_ids": [

      ],
      "image": {
        "id": 6918990,
        "name": "14.04 x64",
        "distribution": "Ubuntu",
        "slug": "ubuntu-16-04-x64",
        "public": true,
        "regions": [
          "nyc1",
          "ams1",
          "sfo1",
          "nyc2",
          "ams2",
          "sgp1",
          "lon1",
          "nyc3",
          "ams3",
          "nyc3"
        ],
        "created_at": "2014-10-17T20:24:33Z",
        "type": "snapshot",
        "min_disk_size": 20,
        "size_gigabytes": 2.34
      },
      "volume_ids": [

      ],
      "size": {
      },
      "size_slug": "s-1vcpu-1gb",
      "networks": {
        "v4": [
          {
            "ip_address": "104.236.32.182",
            "netmask": "255.255.192.0",
            "gateway": "104.236.0.1",
            "type": "public"
          }
        ],
        "v6": [
          {
            "ip_address": "2604:A880:0800:0010:0000:0000:02DD:4001",
            "netmask": 64,
            "gateway": "2604:A880:0800:0010:0000:0000:0000:0001",
            "type": "public"
          }
        ]
      },
      "region": {
        "name": "New York 3",
        "slug": "nyc3",
        "sizes": [

        ],
        "features": [
          "virtio",
          "private_networking",
          "backups",
          "ipv6",
          "metadata"
        ],
        "available": null
      },
      "tags": [

      ]
    }
  ],
  "links": {
    "pages": {
      "last": "https://api.digitalocean.com/v2/droplets?page=3&per_page=1",
      "next": "https://api.digitalocean.com/v2/droplets?page=2&per_page=1"
    }
  },
  "meta": {
    "total": 3
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

local url = 'https://api.digitalocean.com/' .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    user = accessToken,
    password = "",
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


