SHELL := /bin/bash
VERSION ?= 
TAG_PREFIX := v

.PHONY: help tag-commit untag tag changelog version pubspec-version

gen-proto:
	@echo "Generating protobuf..."
	protoc --dart_out=grpc:lib/miru_core/proto/generate --dart_opt=grpc --proto_path=src/miru_core/miru-core src/miru_core/miru-core/proto/*.proto
	@echo "Proto generated!"

enable-proto:
	@echo "Enabling protobuf..."
	dart pub global activate protoc_plugin
	@echo "Proto enabled!"

build-runner:
	@echo "Building runner..."
	dart run build_runner build --delete-conflicting-outputs
	@echo "Runner built!"
runner-build-watch:
	@echo "Building runner..."
	dart run build_runner watch --delete-conflicting-outputs
	@echo "Runner built!"
	
help:
	@echo "Miru Alpha Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make tag-commit TAG=v2.0.2-alpha   Auto tag current commit with given tag"
	@echo "  make tag TAG=v2.0.2-alpha         Same as tag-commit"
	@echo "  make untag TAG=v2.0.2-alpha       Remove local and remote tag"
	@echo "  make changelog                    Generate CHANGELOG.md using git-cliff"
	@echo "  make version                      Show current version from pubspec"
	@echo "  make pubspec-version VERSION=...  Set pubspec version (no +build)"

tag-commit: tag
tag:
	@if [ -z "$(TAG)" ] && [ -z "$(VERSION)" ]; then \
		echo "Error: TAG or VERSION must be specified (e.g., make tag TAG=v2.0.2-alpha)"; \
		exit 1; \
	fi
	$(eval TAG_VAL := $(if $(TAG),$(TAG),$(TAG_PREFIX)$(VERSION)))
	@if git rev-parse -q --verify "refs/tags/$(TAG_VAL)" >/dev/null; then \
		echo "Tag $(TAG_VAL) already exists locally"; \
		git tag -d $(TAG_VAL); \
		echo "Deleted local tag $(TAG_VAL)"; \
	fi
	@git tag -a $(TAG_VAL) -m "Release $(TAG_VAL)"
	@echo "Created tag $(TAG_VAL) on commit $(shell git rev-parse --short HEAD)"

untag:
	@if [ -z "$(TAG)" ] && [ -z "$(VERSION)" ]; then \
		echo "Error: TAG or VERSION must be specified"; \
		exit 1; \
	fi
	$(eval TAG_VAL := $(if $(TAG),$(TAG),$(TAG_PREFIX)$(VERSION)))
	@git tag -d $(TAG_VAL) 2>/dev/null || true
	@git push origin :refs/tags/$(TAG_VAL) 2>/dev/null || true
	@echo "Removed tag $(TAG_VAL) (local and remote if exists)"

changelog:
	@command -v git-cliff >/dev/null 2>&1 || { echo "git-cliff not installed. Install with: cargo install git-cliff"; exit 1; }
	git-cliff -o CHANGELOG.md
	@echo "CHANGELOG.md updated with git-cliff"

version:
	@grep '^version:' pubspec.yaml

pubspec-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION must be specified"; \
		exit 1; \
	fi
	@sed -i "s/^version:.*/version: $(VERSION)/" pubspec.yaml
	@echo "Set pubspec.yaml version to $(VERSION)"
