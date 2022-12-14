GO ?= go
BUF_VERSION=v1.7.0
GRPCURL_VERSION=v1.8.7
PROTOC_GEN_GO=v1.28
PROTOC_GEN_GO_GRPC=v1.2
PROTOC_GEN_CONNECT_GO=v0.4.0
PROTO_GO_TARGET_REPO ?= deploy/proto-go

.PHONY: build
build: generator

.PHONY: install
install:
	$(GO) install github.com/bufbuild/buf/cmd/buf@$(BUF_VERSION)
	$(GO) install github.com/fullstorydev/grpcurl/cmd/grpcurl@$(GRPCURL_VERSION)
	$(GO) install google.golang.org/protobuf/cmd/protoc-gen-go@$(PROTOC_GEN_GO)
	$(GO) install google.golang.org/grpc/cmd/protoc-gen-go-grpc@$(PROTOC_GEN_GO_GRPC)
	$(GO) install github.com/bufbuild/connect-go/cmd/protoc-gen-connect-go@$(PROTOC_GEN_CONNECT_GO)

.PHONY: generator
generator: buf-lint buf-gen-go

.PHONY: buf-lint
buf-lint:
	buf lint
	buf format --diff --exit-code

.PHONY: buf-format
buf-format:
	buf format --diff -w

buf-gen-go:
	buf generate --template buf.gen.yaml

push-to-go-repo:
	cp -r gen/go/* $(PROTO_GO_TARGET_REPO)/
	cd $(PROTO_GO_TARGET_REPO) && $(GO) mod init github.com/apus-run/proto-def-examples || true
	cd $(PROTO_GO_TARGET_REPO) && $(GO) mod tidy
	git config --global user.email "moocss@gmail.com"
	git config --global user.name "moocss"
	(cd $(PROTO_GO_TARGET_REPO) && git add --all && git commit -m "[auto-commit] Generate codes" && git push -f -u origin main) || echo "not pushed"

clean:
	rm -rf gen
