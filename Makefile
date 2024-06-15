OUT			= build
TESTS		= $(OUT)/miroir_test

PREFIX		= /usr/local
BINDIR		= $(PREFIX)/bin

SRC			= $(wildcard include/*/*.?pp)
SRC_TEST	= $(wildcard tests/*.?pp)

release: export CMAKE_BUILD_TYPE=Release
release: build

debug: export CMAKE_BUILD_TYPE=Debug
debug: build

build: $(TESTS)

CMakeLists.txt: .cgen.yml
	-cgen -g

configure: CMakeLists.txt
	cmake \
		-S . \
		-B "$(OUT)" \
		-G "Unix Makefiles" \
		-D CMAKE_EXPORT_COMPILE_COMMANDS=ON

$(TESTS): configure $(SRC) $(SRC_TEST)
	cmake \
		--build "$(OUT)" \
		--target "$(@F)" \
		--parallel

clean:
	$(RM) -r "$(OUT)"

test: $(TESTS)
	"./$(OUT)/miroir_test"

format:
	clang-format -i $(SRC) $(SRC_TEST)

check:
	cppcheck \
		--cppcheck-build-dir="$(OUT)" \
		--language=c++ \
		--std=c++20 \
		--enable=all \
		--check-level=exhaustive \
		--inconclusive \
		--quiet \
		--inline-suppr \
		--suppress=unmatchedSuppression \
		--suppress=missingInclude \
		--suppress=missingIncludeSystem \
		--suppress=unusedStructMember \
		--suppress=unusedFunction \
		--suppress=useStlAlgorithm \
		$(SRC) $(SRC_TEST)

	clang-tidy \
		-p="$(OUT)" \
		--warnings-as-errors=* \
		$(SRC) $(SRC_TEST)

	codespell \
		include \
		tests \
		Makefile \
		README.md \
		LICENSE \
		.cgen.yml

asan: export CMAKE_BUILD_TYPE=Asan
asan: test

ubsan: export CMAKE_BUILD_TYPE=Ubsan
ubsan: test

.PHONY: release debug
.PHONY: configure build clean
.PHONY: test
.PHONY: format check
.PHONY: asan ubsan
