TARGET		= miroir
TARGET_TEST	= miroir_test
OUT			= build

PREFIX		= /usr/local
BINDIR		= $(PREFIX)/bin

SRC			= $(wildcard include/**/*.?pp)
SRC_TEST	= $(wildcard tests/*.?pp)

release: export CMAKE_BUILD_TYPE=Release
release: build

debug: export CMAKE_BUILD_TYPE=Debug
debug: build

build: $(OUT)/$(TARGET)

configure:
	cmake \
		-S . \
		-B "$(OUT)" \
		-G "Unix Makefiles" \
		-D CMAKE_EXPORT_COMPILE_COMMANDS=ON

$(OUT)/$(TARGET): configure $(SRC)
	cmake \
		--build "$(OUT)" \
		--target "$(TARGET)" \
		--parallel

$(OUT)/$(TARGET_TEST): configure $(SRC) $(SRC_TEST)
	cmake \
		--build "$(OUT)" \
		--target "$(TARGET_TEST)" \
		--parallel

clean:
	$(RM) -r "$(OUT)"

install:
	strip "$(OUT)/$(TARGET)"
	install -d "$(DESTDIR)$(BINDIR)"
	install -m 755 "$(OUT)/$(TARGET)" "$(DESTDIR)$(BINDIR)"

uninstall:
	$(RM) "$(DESTDIR)$(BINDIR)/$(TARGET)"

run: $(OUT)/$(TARGET)
	"./$(OUT)/$(TARGET)"

test: $(OUT)/$(TARGET_TEST)
	"./$(OUT)/$(TARGET_TEST)"

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
		-L poost \
		include \
		tests \
		Makefile \
		README \
		LICENSE

asan: export CMAKE_BUILD_TYPE=Asan
asan: test

ubsan: export CMAKE_BUILD_TYPE=Ubsan
ubsan: test
