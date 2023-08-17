# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: fchain android ios fchain-cross evm all test clean bootnode
.PHONY: fchain-linux fchain-linux-386 geth-linux-amd64 geth-linux-mips64 geth-linux-mips64le
.PHONY: fchain-linux-arm fchain-linux-arm-5 geth-linux-arm-6 geth-linux-arm-7 geth-linux-arm64
.PHONY: fchain-darwin fchain-darwin-386 geth-darwin-amd64
.PHONY: fchain-windows fchain-windows-386 geth-windows-amd64

GOBIN = ./build/bin
GO ?= latest
GORUN = go run

fchain:
	$(GORUN) build/ci.go install ./cmd/fchain
	@echo "Done building."
	@echo "Run \"$(GOBIN)/fchain\" to launch fchain."

bootnode:
	$(GORUN) build/ci.go install ./cmd/bootnode
	@echo "Done building."
	@echo "Run \"$(GOBIN)/bootnode\" to launch bootnode."

all:
	$(GORUN) build/ci.go install

android:
	$(GORUN) build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/fchain.aar\" to use the library."
	@echo "Import \"$(GOBIN)/fchain-sources.jar\" to add javadocs"
	@echo "For more info see https://stackoverflow.com/questions/20994336/android-studio-how-to-attach-javadoc"

ios:
	$(GORUN) build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Geth.framework\" to use the library."

test: all
	$(GORUN) build/ci.go test

lint: ## Run linters.
	$(GORUN) build/ci.go lint

clean:
	env GO111MODULE=on go clean -cache
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go install golang.org/x/tools/cmd/stringer@latest
	env GOBIN= go install github.com/kevinburke/go-bindata/go-bindata@latest
	env GOBIN= go install github.com/fjl/gencodec@latest
	env GOBIN= go install github.com/golang/protobuf/protoc-gen-go@latest
	env GOBIN= go install ./cmd/abigen
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

fchain-cross: fchain-linux geth-darwin geth-windows geth-android geth-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/fchain-*

fchain-linux: fchain-linux-386 geth-linux-amd64 geth-linux-arm geth-linux-mips64 geth-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-*

fchain-linux-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/fchain
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep 386

fchain-linux-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/fchain
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep amd64

fchain-linux-arm: fchain-linux-arm-5 geth-linux-arm-6 geth-linux-arm-7 geth-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep arm

fchain-linux-arm-5:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/fchain
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep arm-5

fchain-linux-arm-6:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/fchain
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep arm-6

fchain-linux-arm-7:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/fchain
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep arm-7

fchain-linux-arm64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/fchain
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep arm64

fchain-linux-mips:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/fchain
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep mips

fchain-linux-mipsle:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/fchain
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep mipsle

fchain-linux-mips64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/fchain
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep mips64

fchain-linux-mips64le:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/fchain
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/fchain-linux-* | grep mips64le

fchain-darwin: fchain-darwin-386 geth-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/fchain-darwin-*

fchain-darwin-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/fchain
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-darwin-* | grep 386

fchain-darwin-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/fchain
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-darwin-* | grep amd64

fchain-windows: fchain-windows-386 geth-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/fchain-windows-*

fchain-windows-386:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/fchain
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-windows-* | grep 386

fchain-windows-amd64:
	$(GORUN) build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/fchain
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/fchain-windows-* | grep amd64
