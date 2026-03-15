#!/bin/bash
# Security hook: block WebFetch requests to private/internal network ranges (SSRF prevention)
INPUT=$(cat)
URL=$(echo "$INPUT" | jq -r '.tool_input.url // empty')

[ -z "$URL" ] && exit 0

# Extract hostname
HOST=$(echo "$URL" | sed -E 's|^https?://([^/:]+).*|\1|')

# Block non-HTTPS schemes
if echo "$URL" | grep -qiE '^(http|ftp|file|gopher|dict):'; then
  if ! echo "$URL" | grep -qi '^https:'; then
    jq -n '{ decision: "deny", reason: "Non-HTTPS URL blocked for security" }'
    exit 0
  fi
fi

# Block private IPv4 ranges and localhost
if echo "$HOST" | grep -qE \
  '^(localhost|127\.|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|169\.254\.|0\.0\.0\.0|::1|fc00:|fe80:)'; then
  jq -n '{ decision: "deny", reason: "Request to internal/private network blocked (SSRF prevention)" }'
  exit 0
fi

# Block AWS/GCP/Azure metadata endpoints
if echo "$HOST" | grep -qE '(169\.254\.169\.254|metadata\.google\.internal|169\.254\.170\.2)'; then
  jq -n '{ decision: "deny", reason: "Cloud metadata endpoint blocked (SSRF prevention)" }'
  exit 0
fi

exit 0
