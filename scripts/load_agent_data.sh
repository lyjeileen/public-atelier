#!/bin/bash

register_agents() {
    host=${RUSTIC_AI_HOST:-"http://localhost:8880"}
    echo "host is $host"
    agents_data=$(cat "${DATA_FOLDER:-./data}/agents.json")
    agents_endpoint="/catalog/agents"


    for agent_key in $(echo "$agents_data" | jq -r 'keys[]'); do
        # Extract the entire agent object for the current key
        agent_data=$(echo "$agents_data" | jq -r ".\"$agent_key\"")

        # Create the payload using the entire agent object
        payload=$(jq -n --argjson agent_data "$agent_data" '$agent_data')

        # Send the POST request
        response=$(curl -s -X POST "$host$agents_endpoint" -H "Content-Type: application/json" -d "$payload")

        # Check if the request was successful
        if [ $? -eq 0 ]; then
            echo "Successfully created agent: $agent_key"
        else
            echo "Failed to create agent: $agent_key"
        fi
    done
}

register_agents