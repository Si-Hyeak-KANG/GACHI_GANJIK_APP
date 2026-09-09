# ──────────────────────────────────────────
# 같이간직 Flutter App - Makefile
# ──────────────────────────────────────────

# 기본 명령어
FLUTTER = fvm flutter
DART = fvm dart

# 소셜 로그인 키 등 환경변수 주입 (env.json 은 .gitignore 대상)
ENV = --dart-define-from-file=env.json

# ──────────────────────────────────────────
# 실행
# ──────────────────────────────────────────

## Mock 데이터 기반 실행 (서버 불필요)
mock:
	$(FLUTTER) run $(ENV)

## 실제 서버 연동 실행
real:
	$(FLUTTER) run $(ENV) --dart-define=USE_REAL_API=true

## 특정 기기 지정 실행 (make mock-d device=<device-id>)
mock-d:
	$(FLUTTER) run $(ENV) -d $(device)

real-d:
	$(FLUTTER) run $(ENV) -d $(device) --dart-define=USE_REAL_API=true

# ──────────────────────────────────────────
# 빌드
# ──────────────────────────────────────────

## Android APK (Mock)
apk-mock:
	$(FLUTTER) build apk $(ENV)

## Android APK (Real)
apk-real:
	$(FLUTTER) build apk $(ENV) --dart-define=USE_REAL_API=true

## Android App Bundle (Play Store)
aab:
	$(FLUTTER) build appbundle $(ENV) --dart-define=USE_REAL_API=true

## iOS (Mock)
ios-mock:
	$(FLUTTER) build ios $(ENV) --no-codesign

## iOS (Real)
ios-real:
	$(FLUTTER) build ios $(ENV) --no-codesign --dart-define=USE_REAL_API=true

# ──────────────────────────────────────────
# 개발 도구
# ──────────────────────────────────────────

## 의존성 설치
get:
	$(FLUTTER) pub get

## Isar 코드 생성
gen:
	$(DART) run build_runner build --delete-conflicting-outputs

## 클린 빌드
clean:
	$(FLUTTER) clean
	$(FLUTTER) pub get

## 클린 + Isar 코드 재생성
reset:
	$(FLUTTER) clean
	$(FLUTTER) pub get
	$(DART) run build_runner build --delete-conflicting-outputs

## 정적 분석
analyze:
	$(FLUTTER) analyze

## 테스트
test:
	$(FLUTTER) test

## 기기 목록 확인
devices:
	$(FLUTTER) devices

## CocoaPods 재설치 (iOS 의존성 오류 시)
pod:
	cd ios && pod install --repo-update

.PHONY: mock real mock-d real-d apk-mock apk-real aab ios-mock ios-real \
        get gen clean reset analyze test devices pod