# ── trale build helpers ────────────────────────────────────────────────
# Use `make run` / `make build` instead of raw flutter commands to ensure
# all code-generation steps run first.

SHELL := /bin/bash
export PATH := $(HOME)/.flutter-sdk/flutter/bin:$(PATH)

CHANGELOG_SRC := ../CHANGELOG.md
CHANGELOG_GEN := lib/core/changelog.g.dart

# Screenshot tour settings (override on the command line, e.g.
# `make screenshots THEMES=water DEVICE=emulator-5556`).
DEVICE ?= emulator-5554
THEMES ?= water,berry,forest,amber

# ── Code generation ───────────────────────────────────────────────────

## Regenerate changelog.g.dart from ../CHANGELOG.md
$(CHANGELOG_GEN): $(CHANGELOG_SRC) ../quantumphysique/bin/generate_changelog.dart lib/core/changelog.dart
	dart run quantumphysique:generate_changelog

## Regenerate Hive type adapters
.PHONY: hive
hive:
	flutter packages pub run build_runner build

## Run all code generators
.PHONY: generate
generate: $(CHANGELOG_GEN)

# ── Flutter commands (with auto-generation) ───────────────────────────

.PHONY: run
run: $(CHANGELOG_GEN)
	flutter run

.PHONY: build
build: $(CHANGELOG_GEN)
	flutter build apk --split-per-abi --release

.PHONY: build-aab
build-aab: $(CHANGELOG_GEN)
	flutter build appbundle --release

# Override for a jar: BUNDLETOOL="java -jar /path/to/bundletool-all.jar"
BUNDLETOOL ?= bundletool
KEY_PROPERTIES := android/key.properties
APP_VERSION := $(shell sed -n -E 's/^version: ([0-9.]+)\+.*/\1/p' pubspec.yaml)
AAB := build/app/outputs/bundle/release/app-release.aab
APKS_DIR := build/app/outputs/apks
APKS := $(APKS_DIR)/trale-$(APP_VERSION).apks

## Build the APK set (.apks) for Accrescent from the signed release bundle.
## Needs bundletool and android/key.properties. Recipe is silenced so the
## keystore passwords never reach the terminal or CI log.
.PHONY: build-apks
build-apks: build-aab
	@mkdir -p $(APKS_DIR)
	@KS=$$(sed -n 's/^storeFile=//p' $(KEY_PROPERTIES)); \
	case "$$KS" in /*) ;; *) KS="android/$$KS";; esac; \
	echo "$(BUNDLETOOL) build-apks --bundle=$(AAB) --output=$(APKS)"; \
	$(BUNDLETOOL) build-apks \
		--bundle=$(AAB) \
		--output=$(APKS) \
		--overwrite \
		--ks="$$KS" \
		--ks-key-alias="$$(sed -n 's/^keyAlias=//p' $(KEY_PROPERTIES))" \
		--ks-pass="pass:$$(sed -n 's/^storePassword=//p' $(KEY_PROPERTIES))" \
		--key-pass="pass:$$(sed -n 's/^keyPassword=//p' $(KEY_PROPERTIES))"

.PHONY: analyze
analyze: $(CHANGELOG_GEN)
	flutter analyze

.PHONY: test
test: $(CHANGELOG_GEN)
	flutter test

.PHONY: coverage
coverage: $(CHANGELOG_GEN)
	flutter test --coverage
	@echo "Coverage data written to coverage/lcov.info"
	@command -v genhtml >/dev/null 2>&1 && \
		genhtml coverage/lcov.info -o coverage/html && \
		echo "HTML report: coverage/html/index.html" || \
		echo "(install lcov for HTML report)"

# ── Screenshots ───────────────────────────────────────────────────────

## Capture app screenshots for every theme in light and dark mode.
## Output goes to ../screenshots/<theme>/<light|dark>/<NN_screen>.png.
## Built in profile mode so the debug banner stays out of the images.  The
## capture is a PixelCopy of the app window, so no Android system chrome
## (status bar, navigation bar) ends up in the result.
.PHONY: screenshots
screenshots: $(CHANGELOG_GEN)
	flutter drive \
		--profile \
		--driver=test_driver/screenshot_driver.dart \
		--target=integration_test/screenshots_test.dart \
		--device-id=$(DEVICE) \
		--dart-define=SCREENSHOT_THEMES=$(THEMES)
	@echo "Screenshots written to ../screenshots/"

.PHONY: format
format:
	find lib test -name '*.dart' ! -name '*.g.dart' | xargs dart format

.PHONY: format-check
format-check:
	dart format --set-exit-if-changed .

.PHONY: install-hooks
install-hooks:
	git -C .. config core.hooksPath .githooks
	@echo "Pre-commit hooks installed (using ../.githooks)."

.PHONY: clean
clean:
	flutter clean

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make run        – generate + flutter run"
	@echo "  make build      – generate + flutter build apk"
	@echo "  make build-aab  – generate + flutter build appbundle"
	@echo "  make build-apks – build-aab + bundletool APK set for Accrescent"
	@echo "  make analyze    – generate + flutter analyze"
	@echo "  make test       – generate + flutter test"
	@echo "  make coverage   – generate + flutter test --coverage"
	@echo "  make screenshots – capture screenshots into ../screenshots/"
	@echo "  make format     – dart format ."
	@echo "  make format-check – dart format --set-exit-if-changed"
	@echo "  make install-hooks – install git pre-commit hooks"
	@echo "  make generate   – run all code generators"
	@echo "  make hive       – regenerate Hive adapters"
	@echo "  make clean      – flutter clean"
