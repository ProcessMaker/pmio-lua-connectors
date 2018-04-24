--[[
# [MongoDB connector](https://www.mongodb.com)

## Requirements:

  ```
  sudo luarocks install lua-mongo
  ```

## Input parameters


## Output parameters

  Example response:

  ```

  ```
]]--
local mongo = require('mongo')
local cjson = require("cjson")
-- load driver

local inputVar = cjson.decode(io.stdin:read("*a"))

local host = inputVar.host
local query = cjson.encode(inputVar.query)

local client = mongo.Client('mongodb://' .. host)
local collection = client:getCollection('lua-mongo-test', 'test')

print(query)
local bson = mongo.Javascript(query)

print(bson)

print(collection:count(bson:unpack()))
for document in collection:find(bson:unpack()):iterator() do
    print(document.name)
end
