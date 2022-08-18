INFLUX_TOKEN=$INFLUX_ALL_ACCESS_TOKEN
INFLUX_READ_WRITE_TOKEN=$INFLUX_ALL_ACCESS_TOKEN

echo "Influx token: ${INFLUX_TOKEN}"
echo "Read write token: ${INFLUX_READ_WRITE_TOKEN}"

timestamp=`date +%s`;

# InfluxDB default is 100.

# Get a stack (installed template)
function get_stacks() {
  query=$1
  curl -v --request GET \
    "${INFLUX_URL}/api/v2/stacks$query" \
    --header "Accept: application/json" \
    --header "Authorization: Token ${INFLUX_READ_WRITE_TOKEN}"
}
# get_stacks
# get_stacks 0996e5ac67f78000

function get_stacks_by_name() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/stacks?name=${1}&orgID=$INFLUX_ORG_ID" \
  --header "Accept: application/json" \
	--header "Authorization: Token ${INFLUX_TOKEN}"
}
# get_stacks_by_name

function get_stacks_by_status() {
curl -v --request GET \
	"${INFLUX_URL}/api/v2/stacks?status=${1}" \
	--header "Authorization: Token ${INFLUX_TOKEN}" | jq .
}
# get_stacks_by_status inactive
# get_stacks_by_status active

TEMPLATE_URL="https://raw.githubusercontent.com/influxdata/community-templates/master/linux_system/linux_system.yml"

function create_stack() {

data=@- << EOF
    {
      "description": "My new stack",
      "name": "api-created-stack",
      "orgID": "$INFLUX_ORG_ID",
      "urls": ["$TEMPLATE_URL"]
    }
EOF

echo $data

  curl -v --request POST \
	"${INFLUX_URL}/api/v2/stacks" \
	--header "Authorization: Token ${INFLUX_OP_TOKEN}" \
  --data @- << EOF
    {
      "description": "My new stack",
      "name": "api-created-stack",
      "orgID": "$INFLUX_ORG_ID",
      "urls": ["$TEMPLATE_URL"]
    }
EOF
}

function apply_template_url() {
  curl -v --request POST \
    "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --data @- << EOF
      {
        "orgID": "$INFLUX_ORG_ID",
        "dryRun": true,
        "remotes": [
          {
            "url": "https://raw.githubusercontent.com/influxdata/community-templates/master/linux_system/linux_system.yml"
          },
          {
            "url": "https://raw.githubusercontent.com/influxdata/community-templates/master/aws_lambda/lambda.yml"
          }
        ]
      }
EOF

# More than one url doesn't work:
#
# "remotes": [
#   {
#     "url": "https://raw.githubusercontent.com/influxdata/community-templates/master/linux_system/linux_system.yml"
#   },
#  {
#    "url": "https://raw.githubusercontent.com/influxdata/community-templates/master/aws_lambda/lambda.yml"
#  }
# ]
#
#
}


function apply_template_object() {
  curl -v "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --data @- << EOF
    { "orgID": "$INFLUX_ORG_ID",
      "dryRun": true,
      "template": {
        "contents": [
          {
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Bucket",
            "metadata": {
              "name": "heuristic-sinoussi-004"
            },
            "spec": {
              "name": "docker",
              "retentionRules": [
                {
                  "everySeconds": 604800,
                  "type": "expire"
                }
              ]
            }
          },
          {
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Label",
            "metadata": {
              "name": "unruffled-benz-004"
            },
            "spec": {
              "color": "#326BBA",
              "name": "inputs.cpu"
            }
          }
        ]
      }
    }
EOF
}

function apply_template_objects() {
  curl -v "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --data @- << EOF
    { "orgID": "$INFLUX_ORG_ID",
      "dryRun": true,
      "templates": [
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Label",
            "metadata": {
              "name": "unruffled-benz-001"
            },
            "spec": {
              "color": "#326BBA",
              "name": "inputs.cpu"
            }
          }]
        },
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Bucket",
            "metadata": {
              "name": "heuristic-sinoussi-004"
            },
            "spec": {
              "name": "docker",
              "retentionRules": [
                {
                  "everySeconds": 604800,
                  "type": "expire"
                }
              ]
            }
          }]
        }
      ]
    }
EOF
}

function apply_template_urls_and_objects() {
curl "http://localhost:8086/api/v2/templates/apply" \
  --header "Authorization: Token $INFLUX_ALL_ACCESS_TOKEN" \
  --data @- << EOF
    {
      "orgID": "$INFLUX_ORG_ID",
      "dryRun": true,
      "remotes": [
        {
          "url": "https://raw.githubusercontent.com/influxdata/community-templates/master/aws_lambda/lambda.yml"
        }
      ],
      "templates": [
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Label",
            "metadata": {
              "name": "unruffled-benz-001"
            },
            "spec": {
              "color": "#326BBA",
              "name": "inputs.cpu"
            }
          }]
        },
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Bucket",
            "metadata": {
              "name": "heuristic-sinoussi-004"
            },
            "spec": {
              "name": "docker",
              "retentionRules": [
                {
                  "everySeconds": 604800,
                  "type": "expire"
                }
              ]
            }
          }]
        }
      ]
    }
EOF
}

function apply_template_objects_with_envref() {
  curl -v "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --data @- << EOF
    { "orgID": "$INFLUX_ORG_ID",
      "dryRun": true,
      "envRefs": {
        "linux-cpu-label": "MY-CPU-LABEL",
        "docker-bucket": "MY-DOCKER-BUCKET",
        "docker-spec-1": "MY-DOCKER-SPEC"
      },
      "templates": [
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Label",
            "metadata": {
              "name": {
                "envRef": {
                  "key": "linux-cpu-label"
                }
              }
            },
            "spec": {
              "color": "#326BBA",
              "name": "inputs.cpu"
            }
          }]
        },
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Bucket",
            "metadata": {
              "name": {
                "envRef": {
                  "key": "docker-bucket"
                }
              }
            },
            "spec": {
              "name": {
                "envRef": {
                  "key": "docker-spec-1"
                }
              },
              "retentionRules": [
                {
                  "everySeconds": 604800,
                  "type": "expire"
                }
              ]
            }
          }]
        }
      ]
    }
EOF
}

function apply_template_objects_skipkind() {
  curl -v "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --data @- << EOF
    { "orgID": "$INFLUX_ORG_ID",
      "dryRun": true,
      "envRefs": {
        "linux-cpu-label": "MY-CPU-LABEL",
        "docker-bucket": "MY-DOCKER-BUCKET",
        "docker-spec-1": "MY-DOCKER-SPEC"
      },
      "actions": [
        { "action": "skipKind",
          "properties": {
            "kind": "Bucket"
          }
        },
        { "action": "skipKind",
          "properties": {
            "kind": "Task"
          }
        }
      ],
      "templates": [
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Label",
            "metadata": {
              "name": {
                "envRef": {
                  "key": "linux-cpu-label"
                }
              }
            },
            "spec": {
              "color": "#326BBA",
              "name": "inputs.cpu"
            }
          },
          {
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Task",
            "metadata": {
              "name": "alerting-gates-b84003"
            },
            "every": "1h0m0s",
            "name": "wins",
            "offset": "5m0s",
            "scriptID": "09b2136232083000",
            "scriptParameters": {
                "rangeStart": "task.every",
                "bucket": "air_sensor",
                "filterField": "temperature",
                "groupColumn": "_time"
            }
          }
          ]
        },
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Bucket",
            "metadata": {
              "name": {
                "envRef": {
                  "key": "docker-bucket"
                }
              }
            },
            "spec": {
              "name": {
                "envRef": {
                  "key": "docker-spec-1"
                }
              },
              "retentionRules": [
                {
                  "everySeconds": 604800,
                  "type": "expire"
                }
              ]
            }
          }]
        }
      ]
    }
EOF
}

function apply_template_objects_skipresource() {
  curl -v "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --data @- << EOF
    { "orgID": "$INFLUX_ORG_ID",
      "dryRun": true,
      "envRefs": {
        "linux-cpu-label": "MY-CPU-LABEL",
        "docker-bucket": "MY-DOCKER-BUCKET",
        "docker-spec-1": "MY-DOCKER-SPEC"
      },
      "actions": [
        { "action": "skipKind",
          "properties": {
            "kind": "Bucket"
          }
        },
        { "action": "skipResource",
          "properties": {
            "kind": "Label",
            "templateResourceName": "mem-label"
          }
        }
      ],
      "templates": [
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Label",
            "metadata": {
              "name": {
                "envRef": {
                  "key": "linux-cpu-label"
                }
              }
            },
            "spec": {
              "color": "#326BBA",
              "name": "inputs.cpu"
            }
          },
          {
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Label",
            "metadata": {
              "name": "mem-label"
            },
            "spec": {
              "color": "#326BBA",
              "name": "mem-spec-label"
            }
          }]
        },
        { "contents": [{
            "apiVersion": "influxdata.com/v2alpha1",
            "kind": "Bucket",
            "metadata": {
              "name": {
                "envRef": {
                  "key": "docker-bucket"
                }
              }
            },
            "spec": {
              "name": {
                "envRef": {
                  "key": "docker-spec-1"
                }
              },
              "retentionRules": [
                {
                  "everySeconds": 604800,
                  "type": "expire"
                }
              ]
            }
          }]
        }
      ]
    }
EOF
}

function apply_template_url_with_secret() {
  curl -v --request POST \
    "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token ${INFLUX_ALL_ACCESS_TOKEN}" \
    --data @- << EOF | jq .
      {
        "dryRun": false,
        "orgID": "$INFLUX_ORG_ID",
        "secrets": {
          "SLACK_WEBHOOK": "MY_SECRET_SLACK_WEBHOOK_KEY"
        },
        "remotes": [
          {
            "url": "https://raw.githubusercontent.com/influxdata/community-templates/master/fortnite/fn-template.yml"
          }
        ]
      }
EOF
}

function dryrun() {
  template_url=$1

  curl -v --request POST \
    "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token $INFLUX_ALL_ACCESS_TOKEN" \
    --data @- << EOF | jq .
      {
        "dryRun": true,
        "orgID": "$INFLUX_ORG_ID",
        "remotes": [
          {
            "url": "$template_url"
          }
        ]
      }
EOF
}

function validate() {
  curl -v "${INFLUX_URL}/api/v2/templates/apply" \
    --header "Authorization: Token $INFLUX_ALL_ACCESS_TOKEN" \
    --data @- << EOF | jq .
      {
        "dryRun": true,
        "orgID": "$INFLUX_ORG_ID",
        "template":
          { "contents": [
            {
              "apiVersion": "influxdata.com/v2alpha1",
              "kind": "Foo",
              "metadata": {
                "name": "unruffled-benz-d4d007"
              },
              "spec": {
                "color": "#326BBA",
                "name": "inputs.cpu"
              }
            }
          ]}
      }
EOF
}

function export_task() {
  curl -v "${INFLUX_URL}/api/v2/templates/export" \
    --header "Authorization: Token $INFLUX_ALL_ACCESS_TOKEN" \
    --header "Content-type: application/json" \
    --data @- << EOF
    {
      "resources": [
        {
          "kind": "Task",
          "id": "09b322db6d1b2000"
        }
      ]
    }
EOF
}

# dryrun "https://raw.githubusercontent.com/jstirnaman/community-templates/jstirnaman-bad-example/bad-template/bad-example-template.yml"

function update_stack_names() {
  arr_stackids=$(get_stacks | jq -r '[.["stacks"][].id]|@tsv')
  for id in $arr_stackids
  do
    curl -v --request PATCH "$INFLUX_URL/api/v2/stacks/$id" \
      --header "Authorization: Token $INFLUX_OP_TOKEN" \
      --header "Content-type: application/json" \
      --data @- << EOF
      {
        "name": "project-stack-$id"
      }
EOF
    get_stacks_by_name project-stack-$id | jq '.["stacks"]'
  done

}

update_stack_names