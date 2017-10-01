#!/usr/bin/make

SHELL := /bin/bash
PWD    = $(shell pwd)

PKG  = ./src # $(dir $(wildcard ./*)) # uncomment for implicit submodules
BIN  = darch
GO  := $(realpath ./go)

FIND_STD_DEPS = $(GO) list std | sort | uniq
FIND_PKG_DEPS = $(GO) list -f '{{join .Deps "\n"}}' $(PKG) | sort | uniq | grep -v "^_"
DEPS          = $(shell comm -23 <($(FIND_PKG_DEPS)) <($(FIND_STD_DEPS)))


.PHONY: %

default: test

all: build
build: deps
	$(GO) build -o src/darch $(PKG)
fmt:
	$(GO) fmt $(PKG)
test: test-deps
	$(GO) test $(PKG)
cover: test-deps
	$(GO) test -cover $(PKG)
clean:
	$(GO) clean -i $(PKG)
clean-all:
	$(GO) clean -i -r $(PKG)
deps:
	$(GO) get -d $(PKG)
	$(GO) install $(DEPS)
test-deps: deps
	$(GO) get -d -t $(PKG)
	$(GO) test -i $(PKG)
run: all
	./src/$(BIN) ${ARGS}
