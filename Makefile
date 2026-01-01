gen-proto:
	@echo "Generating Go protobuf code..."
	cd src/miru_core/miru-core && make gen-proto
	@echo "Generating Dart protobuf code..."
	PATH=$(HOME)/.pub-cache/bin:$(PATH) protoc --dart_out=grpc:lib/miru_core/proto/ -I src/miru_core/miru-core/ src/miru_core/miru-core/proto/*.proto
	mv lib/miru_core/proto/proto/* lib/miru_core/proto/
	rm -rf lib/miru_core/proto/proto/
	@echo "Proto generation completed!"
