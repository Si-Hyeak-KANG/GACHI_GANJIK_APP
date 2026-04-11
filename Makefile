# ──────────────────────────────────────────
# 같이간직 Flutter App - Makefile
# ──────────────────────────────────────────

# 기본 명령어
FLUTTER = fvm flutter

# ──────────────────────────────────────────
# 실행
# ──────────────────────────────────────────

## Mock 데이터 기반 실행 (서버 불필요)
mock:
	$(FLUTTER) run

## 실제 서버 연동 실행
real:
	$(FLUTTER) run --dart-define=USE_REAL_API=true

## 특정 기기 지정 실행 (make dev-mock device=<device-id>)
mock-d:
	$(FLUTTER) run -d $(device)

real-d:
	$(FLUTTER) run -d $(device) --dart-define=USE_REAL_API=true

# ──────────────────────────────────────────
# 빌드
# ──────────────────────────────────────────

## Android APK (Mock)
apk-mock:
	$(FLUTTER) build apk

## Android APK (Real)
apk-real:
	$(FLUTTER) build apk --dart-define=USE_REAL_API=true

## Android App Bundle (Play Store)
aab:
	$(FLUTTER) build appbundle --dart-define=USE_REAL_API=true

## iOS (Mock)
ios-mock:
	$(FLUTTER) build ios --no-codesign

## iOS (Real)
ios-real:
	$(FLUTTER) build ios --no-codesign --dart-define=USE_REAL_API=true

# ──────────────────────────────────────────
# 개발 도구
# ──────────────────────────────────────────

## 의존성 설치
get:
	$(FLUTTER) pub get

## Isar 코드 생성
gen:
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

## 클린 빌드
clean:
	$(FLUTTER) clean
	$(FLUTTER) pub get

## 클린 + Isar 코드 재생성
reset:
	$(FLUTTER) clean
	$(FLUTTER) pub get
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

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
