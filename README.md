# pmio-lua-connectors

* Shopify
  - [Admin API](https://help.shopify.com/api/reference)

* Zendesk

  - [Zendesk Core API](https://developer.zendesk.com/rest_api/docs/core/introduction)

## How-to install Lua locally to develop your own connector


### Install Lua

Linux:
```
sudo yum install lua
```

MacOS:
```
brew install lua
```

Validate your installation:

```
/usr/local/bin/lua -v
Lua 5.2.4  Copyright (C) 1994-2015 Lua.org, PUC-Rio
```

### Install [LuaRocks](https://github.com/luarocks/luarocks/wiki/Download)

Linux:

```
sudo yum install readline-devel
```

```sudo yum install luarocks```

OR if there is no luarocks package you'll have to install LuaRocks from the sources:

```
wget https://luarocks.org/releases/luarocks-2.4.3.tar.gz
tar xzf luarocks-2.4.3.tar.gz
./configure --with-lua=/usr/local/
```

MacOS:

Its already comes with LUA package, no need to install separately.

Validate your installation:

```
/usr/local/bin/luarocks
LuaRocks 2.3.0, a module deployment system for Lua
```

### Install network modules

For Linux you'll have to install openssl library if required:

`sudo yum install openssl-devel`

Install network modules:

```
sudo luarocks install luasrcdiet
sudo luarocks install lua-cjson
sudo luarocks install --server=http://luarocks.org/dev ltn12
sudo luarocks install luasec
sudo luarocks install luasocket
```

### Validate everything working

You should be able to run the following LUA script without an error:

```
local https = require("ssl.https")
local ltn12 = require"ltn12"
local cjson = require("cjson")

local inputVar = cjson.decode(io.stdin:read("*a"))
```

by issuing

```
echo '{}' | lua test.lua
```
