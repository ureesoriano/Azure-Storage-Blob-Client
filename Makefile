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

test:
	docker run --rm \
		-v $(shell pwd):/code \
		azure-storage-blob-client:latest \
		prove -l -r t/

test-watch:
	docker run --rm \
		-v $(shell pwd):/code \
		azure-storage-blob-client:latest \
		provewatcher -l -r t/ --watch lib/ --watch t/
