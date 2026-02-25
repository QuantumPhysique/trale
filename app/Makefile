# ── trale build helpers ────────────────────────────────────────────────
# Use `make run` / `make build` instead of raw flutter commands to ensure
# all code-generation steps run first.

SHELL := /bin/bash
export PATH := $(HOME)/.flutter-sdk/flutter/bin:$(PATH)

CHANGELOG_SRC := ../CHANGELOG.md
CHANGELOG_GEN := lib/core/changelog.g.dart

# ── Code generation ───────────────────────────────────────────────────

## Regenerate changelog.g.dart from ../CHANGELOG.md
$(CHANGELOG_GEN): $(CHANGELOG_SRC) tool/generate_changelog.dart lib/core/changelog.dart
	dart run tool/generate_changelog.dart

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

.PHONY: analyze
analyze: $(CHANGELOG_GEN)
	flutter analyze

.PHONY: test
test: $(CHANGELOG_GEN)
	flutter test

.PHONY: clean
clean:
	flutter clean

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make run        – generate + flutter run"
	@echo "  make build      – generate + flutter build apk"
	@echo "  make build-aab  – generate + flutter build appbundle"
	@echo "  make analyze    – generate + flutter analyze"
	@echo "  make test       – generate + flutter test"
	@echo "  make generate   – run all code generators"
	@echo "  make hive       – regenerate Hive adapters"
	@echo "  make clean      – flutter clean"
