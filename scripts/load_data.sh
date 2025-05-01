#!/bin/bash

# URL to send the requests to
host=${RUSTIC_AI_HOST:-"http://localhost:8880"}


# Function to make HTTP POST request and capture id
post_request() {
  local url=$1
  local payload=$2
  local response=$(curl -s -w "\n%{http_code}" -X POST "$url" -H "Content-Type: application/json" -d "$payload")

  # Split the response into body and status
  local http_body=$(echo "$response" | sed '$d')
  local http_code=$(echo "$response" | tail -n 1)

  # Check if the HTTP status code is 201
  if [ "$http_code" -ne 201 ]; then
    echo "Failed to create resource. HTTP status code: $http_code"
    return 1
  fi

  # Use jq to parse and extract the id field from the JSON response body
  local id=$(echo "$http_body" | jq -r '.id')

  # Check if the id extraction was successful
  if [ -z "$id" ]; then
    echo "Failed to extract id from response"
    return 1
  fi

  # Return the id
  echo "$id"
}

org_id="${ORG_ID:-acmeorganizationid}"
author_id=${AUTHOR_ID:-dummyuserid}


# Create categories and store IDs in an associative array
cat_endpoint="/catalog/categories/"
categories=('Business' 'Entertainment' 'Productivity' 'Research' 'Finance')
declare -A category_map
# Iterate over the array of strings and perform POST requests
for name in "${categories[@]}"; do
  # Define the base JSON payload with the current name
  cat_payload="{\"name\": \"$name\", \"description\": \"Description for $name\"}"
  # Make POST request and capture id
  id=$(post_request "$host$cat_endpoint" "$cat_payload")
  if [ $? -eq 0 ]; then
    # Store the id in the associative array
    category_map["$name"]="$id"
  else
    echo "Failed to create resource for \"$name\"."
  fi
done

# Function to fetch category id using the string
get_category_id() {
  local name=$1
  echo "${category_map[$name]}"
}


# Define common fields to append, using variable interpolation
common_fields='"author_id": "'"$author_id"'", "organization_id": "'"$org_id"'","exposure":"public","version":"v1"'

## Print the category_map for debugging
#echo "Category map:"
#for category in "${!category_map[@]}"; do
#  echo "Category: $category, ID: ${category_map[$category]}"
#done



# Array of blueprints each including a category name
blueprints_file="${DATA_FOLDER:-./data}/apps.json"

bp_endpoint="/catalog/blueprints/"
# Loop through the payloads and send the HTTP POST requests
cat "$blueprints_file" | jq -c '.[]' | while read -r payload; do
  # Extract the category name from the payload
    category_name=$(echo "$payload" | jq -r '.category_name')
    category_id=$(get_category_id "$category_name")
    echo "$category_name"

    # Extract name and description from the payload
    name=$(echo "$payload" | jq -r '.name')
    description=$(echo "$payload" | jq -r '.description')

    new_payload=$(echo "$payload" | jq --arg cat_id "$category_id" --arg name "$name" --arg desc "$description" '.category_id = $cat_id | del(.category_name) | .spec.name = $name | .spec.description = $desc')

    full_payload=$(echo "$new_payload" | jq --argjson common_fields "{$common_fields}" '. + $common_fields')

#    echo "$full_payload"
    bp_id=$(post_request "$host$bp_endpoint" "$full_payload")
    if [ $? -eq 0 ]; then
        echo "$bp_id"
      else
        echo "Failed to create blueprint for \"$name\""
    fi
done