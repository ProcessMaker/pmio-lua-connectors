--[[

# [Hudson API](http://javadoc.jenkins.io/hudson/model/Hudson) connector.

### Authorization

Authorization use [Basic autorization](https://wiki.jenkins.io/display/JENKINS/Authenticating+scripted+clients).

## Input parameters

* jenkins_url - jenkins_url e.g. 'https://buildbot.processmaker.net/'.
* api_endpoint - API endpoint URI, e.g. `job/ProcessMakerCore/api/json?pretty=true`.
* user - username.
* password - your password.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.
Example connector output parameters:
```
"jobs" : [
    {
      "_class" : "org.jenkinsci.plugins.workflow.job.WorkflowJob",
      "name" : "PMCORE-376-as-a-po-i-want-to-have-messag",
      "url" : "https://buildbot.processmaker.net/job/ProcessMakerCore/job/PMCORE-376-as-a-po-i-want-to-have-messag/",
      "color" : "blue"
    },
    {
      "_class" : "org.jenkinsci.plugins.workflow.job.WorkflowJob",
      "name" : "PMCORE-409-oauth2-client-credentials-aut",
      "url" : "https://buildbot.processmaker.net/job/ProcessMakerCore/job/PMCORE-409-oauth2-client-credentials-aut/",
      "color" : "blue"
    },
    {
      "_class" : "org.jenkinsci.plugins.workflow.job.WorkflowJob",
      "name" : "PMIO-1019-rename-api-endpoints",
      "url" : "https://buildbot.processmaker.net/job/ProcessMakerCore/job/PMIO-1019-rename-api-endpoints/",
      "color" : "blue"
    },
    {
      "_class" : "org.jenkinsci.plugins.workflow.job.WorkflowJob",
      "name" : "PMIO-420",
      "url" : "https://buildbot.processmaker.net/job/ProcessMakerCore/job/PMIO-420/",
      "color" : "blue"
    },
  ]
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

local hudson_url = inputVar.hudson_url
local user = inputVar.user
local password = inputVar.password

local url = hudson_url .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    user = user,
    password = password,
    headers = {
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