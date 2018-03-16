--[[

# [Goodle Cloud Vision API](https://cloud.google.com/vision/docs/other-features?) connector.

### Authorization

Authorization use [API key](https://cloud.google.com/vision/docs/auth?).


## Input parameters

* api_key - your api key.
* image_uri - link to your image. e.g. `https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flasche_Coca-Cola_0%2C2_Liter.jpg/220px-Flasche_Coca-Cola_0%2C2_Liter.jpg`
* post_data - optional JSON string used to post data.

## Output parameters

All connector output parameters could be used in PMIO Service Task output parameters as a value placeholders in curly braces.

Example connector output parameters:

```
{
  "responses": [
      {
          "logoAnnotations": [
              {
                  "mid": "/m/064d7",
                  "description": "Coca-Cola",
                  "score": 0.28110546,
                  "boundingPoly": {
                  }
              }
          ],
          "labelAnnotations": [
              {
                  "mid": "/m/0271t",
                  "description": "drink",
                  "score": 0.7962847,
                  "topicality": 0.7962847
              },
              {
                  "mid": "/m/01yvs",
                  "description": "coca cola",
                  "score": 0.7898849,
                  "topicality": 0.7898849
              },
          ],
          "safeSearchAnnotation": {
              "adult": "VERY_UNLIKELY",
              "spoof": "VERY_UNLIKELY",
              "medical": "VERY_UNLIKELY",
              "violence": "VERY_UNLIKELY",
              "racy": "VERY_UNLIKELY"
          },
          "imagePropertiesAnnotation": {
              "dominantColors": {
                  "colors": [
                      {
                          "color": {
                              "red": 203,
                              "green": 76,
                              "blue": 88
                          },
                          "score": 0.108819894,
                          "pixelFraction": 0.0073052905
                      },
                  ]
              }
          },
          "webDetection": {
              "webEntities": [
                  {
                      "entityId": "/m/01yvs",
                      "score": 3.982,
                      "description": "Coca-Cola"
                  },
                  {
                      "entityId": "/m/06qrr",
                      "score": 2.8016,
                      "description": "Fizzy Drinks"
                  },
              ],
              "fullMatchingImages": [
                  {
                      "url": "http://libanonskajidelna.cz/wp-content/uploads/2015/10/Flasche_Coca-Cola_02_Liter.jpg"
                  },
              ],
              "visuallySimilarImages": [
                  {
                      "url": "https://www.colonialspirits.com/wp-content/uploads/2016/01/coca-cola-2-liter.jpg"
                  },
              ],
              "bestGuessLabels": [
                  {
                      "label": "coca cola",
                      "languageCode": "en"
                  }
              ]
          }
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

local apiKey = inputVar.api_key
local imageUri = inputVar.image_uri

local url = 'https://vision.googleapis.com/v1/images:annotate?key=' .. apiKey

reqbody = cjson.encode({
   ["requests"] = {
  {
   ["features"] = {
    {
     ["type"] = "LABEL_DETECTION",
    },
    {
      ["type"] = "TEXT_DETECTION"
    },
    {
      ["type"] = "FACE_DETECTION",
    },
    {
      ["type"] = "IMAGE_PROPERTIES",
    },
    {
      ["type"] = "LANDMARK_DETECTION",
    },
    {
      ["type"] = "LOGO_DETECTION",
    },
    {
      ["type"] = "SAFE_SEARCH_DETECTION",
    },
    {
      ["type"] = "WEB_DETECTION",
    }
   },
   ["image"] = {
    ["source"] = {
     ["imageUri"] = imageUri,
    }
   }
  }
 }
})

r, c,  h = https.request{
    url = url,
    method =  'POST',
    headers = {
         ["Content-Type"] = "application/json",
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


