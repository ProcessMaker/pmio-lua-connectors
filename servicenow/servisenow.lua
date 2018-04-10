--[[
# [ServiceNow API](https://developer.servicenow.com/app.do#!/rest_api_doc?v=jakarta&id=r_TableAPI-GET) connector.

### Authorization

Authorization use - Basic autorization.

## Input parameters

* instance_url - your instance_url e.g. 'https://dev17434.service-now.com/'.
* api_endpoint - API endpoint URI, e.g. `api/now/table/problem?sysparm_limit=1`.
* user - username with access to your instance.
* password - your password.
* method - optional request method, defauls to `GET`, could be `GET`, `POST`, `PUT`, `DELETE`.
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.
Example connector output parameters:
```
{
  "result": [
    {
      "parent": "",
      "made_sla": "true",
      "watch_list": "",
      "upon_reject": "cancel",
      "sys_updated_on": "2016-01-19 04:52:04",
      "approval_history": "",
      "number": "PRB0000050",
      "sys_updated_by": "glide.maint",
      "opened_by": {
        "link": "https://instance.service-now.com/api/now/table/sys_user/glide.maint",
        "value": "glide.maint"
      },
      "user_input": "",
      "sys_created_on": "2016-01-19 04:51:19",
      "sys_domain": {
        "link": "https://instance.service-now.com/api/now/table/sys_user_group/global",
        "value": "global"
      },
      "state": "4",
      "sys_created_by": "glide.maint",
      "knowledge": "false",
      "order": "",
      "closed_at": "2016-01-19 04:52:04",
      "cmdb_ci": {
        "link": "https://instance.service-now.com/api/now/table/cmdb_ci/55b35562c0a8010e01cff22378e0aea9",
        "value": "55b35562c0a8010e01cff22378e0aea9"
      },
      "delivery_plan": "",
      "impact": "3",
      "active": "false",
      "work_notes_list": "",
      "business_service": "",
      "priority": "4",
      "sys_domain_path": "/",
      "time_worked": "",
      "expected_start": "",
      "rejection_goto": "",
      "opened_at": "2016-01-19 04:49:47",
      "business_duration": "1970-01-01 00:00:00",
      "group_list": "",
      "work_end": "",
      "approval_set": "",
      "wf_activity": "",
      "work_notes": "",
      "short_description": "Switch occasionally drops connections",
      "correlation_display": "",
      "delivery_task": "",
      "work_start": "",
      "assignment_group": "",
      "additional_assignee_list": "",
      "description": "Switch occasionally drops connections",
      "calendar_duration": "1970-01-01 00:02:17",
      "close_notes": "updated firmware",
      "sys_class_name": "problem",
      "closed_by": "",
      "follow_up": "",
      "sys_id": "04ce72c9c0a8016600b5b7f75ac67b5b",
      "contact_type": "phone",
      "urgency": "3",
      "company": "",
      "reassignment_count": "",
      "activity_due": "",
      "assigned_to": "",
      "comments": "",
      "approval": "not requested",
      "sla_due": "",
      "comments_and_work_notes": "",
      "due_date": "",
      "sys_mod_count": "1",
      "sys_tags": "",
      "escalation": "0",
      "upon_approval": "proceed",
      "correlation_id": "",
      "location": ""
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

local mime = require("mime")

local inputVar = cjson.decode(io.stdin:read("*a"))

local respbody = {}
local reqbody = inputVar.post_data and cjson.encode(inputVar.post_data) or ''

local instanceUrl = inputVar.instance_url
local user = inputVar.user
local password = inputVar.password

local url = instanceUrl .. inputVar.api_endpoint

local method = inputVar.method and inputVar.method or 'GET'

r, c,  h = https.request{
    url = url,
    method = method,
    user = user,
    password = password,
    headers = {
         ["Accept"] = "application/json",
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