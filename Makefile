.SILENT:
.PHONY: build-image shell

build-image:
	docker build \
		-t azure-storage-blob-client:latest \
		.

shell:
	docker run --rm -ti \
		-v $(shell pwd):/code \
		azure-storage-blob-client:latest
