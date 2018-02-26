--[[
# MySQL connector

## Requirements:

  * lua-cjson
  * [luasql-mysql](https://keplerproject.github.io/luasql/index.html)

  ```
  sudo luarocks install luasql-mysql
  sudo luarocks install lua-cjson
  ```

## Input parameters

  * database - name of database to connect
  * username - username to MySQL server
  * password - password for username
  * host - host of MySQL (default: 'localhost')
  * port - port of MySQL (default: 3306)
  * sqlQuery - SQL query to execute, e.g. `SELECT name, email from people`


## Output parameters

  Example response:

  ```
  {"name":"Jose das Couves","email":"jose@couves.com"}
  {"name":"Manoel Joaquim","email":"manoel.joaquim@cafundo.com"}
  {"name":"Maria das Dores","email":"maria@dores.com"}
  ```
]]--
local cjson = require("cjson")
-- load driver
local driver = require "luasql.mysql"

local inputVar = cjson.decode(io.stdin:read("*a"))

local database = inputVar.database
local username = inputVar.username
local password = inputVar.password
local host = inputVar.host or 'localhost'
local port = inputVar.port or 3306
local sqlQuery = inputVar.sql_query

-- create environment object
env = assert (driver.mysql())
-- connect to data source
con = assert (env:connect(database, username, password, host, port))
-- retrieve a cursor
cur = assert (con:execute(sqlQuery))
-- print all rows
row = cur:fetch ({}, "a")
while row do
  print(cjson.encode(row))
  -- reusing the table of results
  row = cur:fetch (row, "a")
end
-- close everything
cur:close() -- already closed because all the result set was consumed
con:close()
env:close()