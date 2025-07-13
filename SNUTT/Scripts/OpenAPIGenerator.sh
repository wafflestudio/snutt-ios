#!/bin/bash

set -e

CONFIG=${1}

if [[ -z "$CONFIG" ]]; then
    echo "❌ Configuration is required"
    echo "Usage: $0 [dev|prod]"
    exit 1
fi

TYPES_OUTPUT_DIR="Modules/Feature/APIClientInterface/Sources/Generated"
CLIENT_OUTPUT_DIR="Modules/Feature/APIClient/Sources/Generated"

generate_for_config() {
    local config=$1
    local spec_file="OpenAPI/openapi-${config}.json"
    
    if [[ ! -f "$spec_file" ]]; then
        echo "❌ OpenAPI spec file not found: $spec_file"
        return 1
    fi
    
    echo "🚀 Generating OpenAPI code for $config..."
    
    # Types 생성
    echo "  📝 Generating Types..."
    mint run apple/swift-openapi-generator \
        swift-openapi-generator generate \
        --config OpenAPI/openapi-generator-config.yaml \
        --output-directory "$TYPES_OUTPUT_DIR" \
        --mode types \
        "$spec_file"
    
    # Client 생성
    echo "  🔧 Generating Client..."
    mint run apple/swift-openapi-generator \
        swift-openapi-generator generate \
        --config OpenAPI/openapi-generator-config.yaml \
        --output-directory "$CLIENT_OUTPUT_DIR" \
        --mode client \
        "$spec_file"
    
    # Client.swift에 import APIClientInterface 추가
    sed -i '' '1a\
import APIClientInterface
' "$CLIENT_OUTPUT_DIR/Client.swift"
    
    echo "✅ OpenAPI code generated successfully for $config"
}

# 출력 디렉터리 생성
mkdir -p "$TYPES_OUTPUT_DIR"
mkdir -p "$CLIENT_OUTPUT_DIR"

case $CONFIG in
    "dev")
        generate_for_config "dev"
        ;;
    "prod")
        generate_for_config "prod"
        ;;
    *)
        echo "❌ Unknown configuration: $CONFIG"
        echo "Usage: $0 [dev|prod]"
        exit 1
        ;;
esac

echo "🎉 OpenAPI generation completed!" 
