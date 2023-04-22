#!/bin/bash

# Sign in with email and password to obtain the ID token
response=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"returnSecureToken\":true}" \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}")

id_token=$(echo "${response}" | jq -r '.idToken')

if [ "${id_token}" == "null" ]; then
  echo "Failed to sign in and obtain ID token"
  echo "${response}"
  exit 1
fi

# Make the request to get the profile
echo "Requesting profile from https://${DOMAIN}/api/profiles/me"
curl -s -X GET -H "Authorization: Bearer ${id_token}" -H "Content-Type: application/json" "https://${DOMAIN}/api/profiles/me"