SHELL := /bin/bash
VERSION ?=
TAG_PREFIX := v

# Version rule: X.Y.Z or X.Y.Z-<word> (e.g. 2.0.3, 2.0.3-alpha).
# Never -alphaN, never +N: Android versionCode is derived in CI from git
# history (--build-number) and must never appear in the version string.
#
# Release flow: `make release VERSION=...` pushes the tag, and the Alpha
# Release CI regenerates CHANGELOG.md, commits it, retags and builds.

.PHONY: help tag-commit tag push-tag release untag changelog version pubspec-version

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
	@echo "Version rule: X.Y.Z or X.Y.Z-<word> — no -alphaN, no +N."
	@echo ""
	@echo "Targets:"
	@echo "  make release VERSION=2.0.3-alpha  Tag HEAD + push -> CI releases"
	@echo "  make tag TAG=v2.0.3-alpha         Tag current commit (local only)"
	@echo "  make tag-commit TAG=v2.0.3-alpha  Same as tag"
	@echo "  make push-tag TAG=v2.0.3-alpha    Push existing tag (triggers CI)"
	@echo "  make untag TAG=v2.0.3-alpha       Remove local and remote tag"
	@echo "  make changelog                    Regenerate CHANGELOG.md (git-cliff)"
	@echo "  make version                      Show pubspec version"
	@echo "  make pubspec-version VERSION=...  Set pubspec version"

# Tag HEAD with an annotated release tag. Accepts TAG=v2.0.3-alpha or
# VERSION=2.0.3-alpha (v added automatically). Refuses to overwrite an
# existing local or remote tag; `make untag` is the explicit way out.
tag-commit: tag
tag:
	$(eval VERSION_VAL := $(VERSION:v%=%))
	$(eval TAG_VAL := $(if $(TAG),$(TAG),$(TAG_PREFIX)$(VERSION_VAL)))
	@if [ -z "$(TAG)" ] && [ -z "$(VERSION_VAL)" ]; then \
		echo "Error: TAG or VERSION must be specified (e.g., make tag VERSION=2.0.3-alpha)"; \
		exit 1; \
	fi
	@if ! [[ "$(TAG_VAL)" =~ ^$(TAG_PREFIX)[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z-]+)?$$ ]]; then \
		echo "Error: invalid tag '$(TAG_VAL)' — must be $(TAG_PREFIX)X.Y.Z or $(TAG_PREFIX)X.Y.Z-<word> (no -alphaN, no +N)"; \
		exit 1; \
	fi
	@if git rev-parse -q --verify "refs/tags/$(TAG_VAL)" >/dev/null; then \
		echo "Error: tag $(TAG_VAL) already exists locally — make untag TAG=$(TAG_VAL) first"; \
		exit 1; \
	fi
	@if git ls-remote --exit-code --tags origin "refs/tags/$(TAG_VAL)" >/dev/null 2>&1; then \
		echo "Error: tag $(TAG_VAL) already exists on origin — make untag TAG=$(TAG_VAL) first"; \
		exit 1; \
	fi
	@git tag -a "$(TAG_VAL)" -m "Release $(TAG_VAL)"
	@echo "Created tag $(TAG_VAL) on $$(git rev-parse --short HEAD)"

# Push an existing tag; the Alpha Release CI does everything else.
push-tag:
	@if [ -z "$(TAG)" ]; then \
		echo "Error: TAG must be specified (e.g., make push-tag TAG=v2.0.3-alpha)"; \
		exit 1; \
	fi
	@git push origin "refs/tags/$(TAG)"
	@echo "Pushed $(TAG) — Alpha Release CI triggered (changelog commit, retag, builds)"

# One-command release: validate, tag HEAD, push the tag.
release: tag
	$(eval VERSION_VAL := $(VERSION:v%=%))
	$(eval TAG_VAL := $(if $(TAG),$(TAG),$(TAG_PREFIX)$(VERSION_VAL)))
	@git push origin "refs/tags/$(TAG_VAL)"
	@echo "Pushed $(TAG_VAL) — Alpha Release CI triggered (changelog commit, retag, builds)"

untag:
	$(eval VERSION_VAL := $(VERSION:v%=%))
	$(eval TAG_VAL := $(if $(TAG),$(TAG),$(TAG_PREFIX)$(VERSION_VAL)))
	@if [ -z "$(TAG)" ] && [ -z "$(VERSION_VAL)" ]; then \
		echo "Error: TAG or VERSION must be specified"; \
		exit 1; \
	fi
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
	@if ! [[ "$(VERSION)" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z-]+)?$$ ]]; then \
		echo "Error: invalid version '$(VERSION)' — allowed: X.Y.Z or X.Y.Z-<word> (no -alphaN, no +N)"; \
		exit 1; \
	fi
	@sed -i "s/^version:.*/version: $(VERSION)/" pubspec.yaml
	@echo "Set pubspec.yaml version to $(VERSION)"
