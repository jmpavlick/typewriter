module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as D
import Shape
import Test exposing (..)


suite : Test
suite =
    test "should decode the value OK" <|
        \() ->
            D.decodeString Shape.decoder simpleObjJsonStr
                |> Debug.log "shape output"
                |> Expect.ok


simpleObjJsonStr : String
simpleObjJsonStr =
    """
{
  "age": {
    "def": {
      "abort": false,
      "check": "number_format",
      "format": "safeint",
      "type": "number"
    },
    "format": "safeint",
    "isFinite": true,
    "isInt": true,
    "maxValue": 9007199254740991,
    "minValue": -9007199254740991,
    "type": "number"
  },
  "name": {
    "def": {
      "type": "string"
    },
    "format": null,
    "maxLength": null,
    "minLength": null,
    "type": "string"
  },
  "nullableStr": {
    "def": {
      "innerType": {
        "def": {
          "type": "string"
        },
        "format": null,
        "maxLength": null,
        "minLength": null,
        "type": "string"
      },
      "type": "nullable"
    },
    "type": "nullable"
  },
  "nullishStr": {
    "def": {
      "innerType": {
        "def": {
          "innerType": {
            "def": {
              "type": "string"
            },
            "format": null,
            "maxLength": null,
            "minLength": null,
            "type": "string"
          },
          "type": "nullable"
        },
        "type": "nullable"
      },
      "type": "optional"
    },
    "type": "optional"
  },
  "optStr": {
    "def": {
      "innerType": {
        "def": {
          "type": "string"
        },
        "format": null,
        "maxLength": null,
        "minLength": null,
        "type": "string"
      },
      "type": "optional"
    },
    "type": "optional"
  },
  "weight": {
    "def": {
      "checks": [],
      "type": "number"
    },
    "format": null,
    "isFinite": true,
    "isInt": false,
    "maxValue": null,
    "minValue": null,
    "type": "number"
  }
}
"""
