--[[
# MySQL connector

## Requirements:

  * lua-cjson
  * [luasql](https://keplerproject.github.io/luasql/index.html)

  ```
  sudo luarocks install lua-cjson

  sudo luarocks install luasql-mysql
  or
  sudo luarocks install luasql-postgres
  ```

## Input parameters

  * driver - required driver ("mysql" or "postgres")
  * database - name of database to connect
  * username - username to server
  * password - password for username
  * host - host of server (default: 'localhost')
  * port - port of server (default: 3306)
  * sqlQuery - SQL query to execute, e.g. `SELECT name, email from people`


## Output parameters

  Example response:

  ```
  [
    {"name":"Jose das Couves","email":"jose@couves.com"}
    {"name":"Manoel Joaquim","email":"manoel.joaquim@cafundo.com"}
    {"name":"Maria das Dores","email":"maria@dores.com"}
  ]
  ```
]]--
local cjson = require("cjson")

local inputVar = cjson.decode(io.stdin:read("*a"))

-- load driver
local driver = nil

if inputVar.driver == "mysql" then
  driver = require "luasql.mysql"
  -- create environment object
  env = assert (driver.mysql())
elseif inputVar.driver == "postgres" then
  driver = require "luasql.postgres"
  -- create environment object
  env = assert (driver.postgres())
end

local database = inputVar.database
local username = inputVar.username
local password = inputVar.password
local host = inputVar.host or 'localhost'
local port = inputVar.port or 3306
local sqlQuery = inputVar.sql_query

-- connect to data source
con = assert (env:connect(database, username, password, host, port))
-- retrieve a cursor
cur = assert (con:execute(sqlQuery))
-- print all rows
local rows = {}
row = cur:fetch ({}, "a")
while row do
  rows[#rows+1] = row
  row = cur:fetch ({}, "a")
end
print(cjson.encode(rows))
-- close everything
cur:close() -- already closed because all the result set was consumed
con:close()
env:close()