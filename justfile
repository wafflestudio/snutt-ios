# 사용 가능한 전체 명령어를 보려면: just --list

# Tuist 프로젝트 생성 및 Xcode 열기
generate:
    @pre-commit install
    @mise exec -- tuist generate --no-open
    @just certs
    @xed .

# OpenAPI 스펙 다운로드 및 코드 생성 (개발 서버)
openapi-dev:
    @swift Scripts/OpenAPIDownloader.swift dev
    @bash Scripts/OpenAPIGenerator.sh dev

# OpenAPI 스펙 다운로드 및 코드 생성 (프로덕션 서버)
openapi-prod:
    @swift Scripts/OpenAPIDownloader.swift prod
    @bash Scripts/OpenAPIGenerator.sh prod

# 개발 인증서 및 프로비저닝 프로파일 동기화 (읽기 전용)
certs:
    @cd fastlane && mise exec -- bundle exec fastlane sync_dev_certificates

# 프로덕션 인증서 및 프로비저닝 프로파일 동기화 (권한 필요)
deploy-certs:
    @cd fastlane && mise exec -- bundle exec fastlane sync_prod_certificates

# 새 디바이스 등록 및 프로비저닝 프로파일 업데이트 (권한 필요)
register-device:
    @cd fastlane && mise exec -- bundle exec fastlane add_device

# Swift 코드 자동 포맷팅 (커밋 시 자동 실행)
# git이 추적하거나 새로 추가된 파일만 포맷해서, gitignore된 생성 코드(**/Generated 등)는 건드리지 않음
format:
    git ls-files -z --cached --others --exclude-standard -- '*.swift' | xargs -0 swift-format format --in-place

# 코드 품질 검사 (의존성, import, 포맷 등)
check:
    @mise exec -- tuist install
    @mise exec -- tuist inspect implicit-imports
    @just format

# 의존성 검사 및 모듈 테스트 실행
test:
    @mise exec -- tuist install
    @mise exec -- tuist inspect implicit-imports
    @mise exec -- tuist test ModuleTests


