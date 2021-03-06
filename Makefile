# Copyright © 2019 The Homeport Team
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

sources := $(wildcard cmd/dyff/*.go internal/cmd/*.go pkg/dyff/*.go)

.PHONY: all clean fmt gobuild vet lint gocyclo misspell ginkgo test build build-all

all: clean test build

clean:
	@rm -rf binaries internal/cmd/cmd.coverprofile pkg/dyff/dyff.coverprofile
	@go clean -i -cache $(shell go list ./...)

fmt: $(sources)
	@GO111MODULE=on gofmt -s -w $(sources)
	@GO111MODULE=on goimports -w $(sources)

gobuild: $(sources)
	@GO111MODULE=on go build ./...

vet: gobuild
	@GO111MODULE=on go vet $(shell go list ./...)

lint: gobuild
	@GO111MODULE=on golint -set_exit_status $(shell go list ./...)

gocyclo: gobuild
	@GO111MODULE=on gocyclo -over 15 $(sources)

misspell: gobuild
	@misspell -error README.md $(sources)

ginkgo: gobuild
	@GO111MODULE=on ginkgo \
		-r \
		-randomizeAllSpecs \
		-randomizeSuites \
		-failOnPending \
		-trace \
		-race \
		-nodes=4 \
		-compilers=2 \
		-cover

test: vet lint gocyclo misspell ginkgo

build: $(sources)
	@scripts/compile-version.sh --local

build-all: $(sources)
	@scripts/compile-version.sh --all
