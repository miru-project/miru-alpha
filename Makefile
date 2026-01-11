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
build_runner_watch:
	@echo "Building runner..."
	dart run build_runner watch --delete-conflicting-outputs
	@echo "Runner built!"
# build android shared library
build-android:
	cd src/miru_core/miru-core/binary && gomobile bind -ldflags="-s -w -checklinkname=0" -o ../../android/libmiru-core.aar -target=android -androidapi 28 
