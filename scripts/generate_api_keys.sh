#!/bin/bash
# Simple script to verify API keys exist
# The actual api_keys.dart file is already committed to the repo

API_KEYS_FILE="tokerrgjik_mobile/lib/config/api_keys.dart"

if [ -f "$API_KEYS_FILE" ]; then
    echo "✅ API keys file found: $API_KEYS_FILE"
    echo "✅ Build can proceed"
    exit 0
else
    echo "❌ Error: $API_KEYS_FILE not found!"
    echo "❌ Please ensure api_keys.dart is committed to the repository"
    exit 1
fi
