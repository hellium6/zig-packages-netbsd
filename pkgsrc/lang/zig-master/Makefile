# $NetBSD: Makefile,v 1.42 2024/08/10 10:19:01 nia Exp $

## Update DISTNAME according to the latest master download URL and run
## "make makesum" after that.
## Example: If the URL is:
## https://ziglang.org/builds/zig-0.16.0-dev.191+9fa2394f8.tar.xz
## then this value would be: zig-0.16.0-dev.191+9fa2394f8
## Meaning, filename minus the .tar.xz extension
DISTNAME=	zig-0.16.0-dev.205+4c0127566
## To make this a separate package than lang/zig
PKGNAME=	${DISTNAME:S/zig-/zig-master-/}
CATEGORIES=	lang
## https://ziglang.org/builds/ is the official
# MASTER_SITES=	https://ziglang.org/builds/
## Alternate mirror
MASTER_SITES=	https://zig.linus.dev/zig/
EXTRACT_SUFX=	.tar.xz
## Used mainly for /usr/pkg/xx directory and binary symlink name.
## e.g. If this is "zig-0.16.0" (a) zig will be installed in
## /usr/pkg/zig-0.16.0, (b) symlinked as /usr/pkg/bin/zig-0.16.0 and
## (c) can be used by running "zig-0.16.0". "+" causes Zig binary to not
## be available on double tab press. So "+" should not be included here.
## Optionally build number can be removed to make it shorter.
PACKAGE_SLUG=	zig-master

REQUIRED_LLVM_MAJOR_VERSION=	21
# .info "(i) Using LLVM ${REQUIRED_LLVM_MAJOR_VERSION}"


MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	https://ziglang.org/
COMMENT=	Programming language designed for robustness and clarity (prefix isolated)
LICENSE=	mit

# Fails to build in chroot on netbsd: https://github.com/ziglang/zig/issues/19756
USE_CXX_FEATURES+=	c++17
USE_LANGUAGES=		c c++
USE_TOOLS+=		bash:run

CMAKE_CONFIGURE_ARGS+=	-DCMAKE_BUILD_TYPE=Release
CMAKE_CONFIGURE_ARGS+=	-DZIG_SHARED_LLVM=ON
# avoid full-cu-features available to build host,
# in other words ensure that we run everywhere
CMAKE_CONFIGURE_ARGS+=	-DZIG_TARGET_MCPU=baseline
#CMAKE_CONFIGURE_ARGS+=	-DZIG_PIE=ON

## Make it see files from the path of lang/llvmXX
.include "../../lang/llvm${REQUIRED_LLVM_MAJOR_VERSION}/isolatedversion.mk"
LDFLAGS+=		-L${LLVM_ISOLATED_PREFIX}/lib -Wl,-R${LLVM_ISOLATED_PREFIX}/lib
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_CXX_LINK_FLAGS=${LDFLAGS:Q}
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_C_LINK_FLAGS=${LDFLAGS:Q}
## Because zig build can't find libxml etc. if not set to /usr/pkg
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_PREFIX_PATH=${PREFIX}
## Fix for "libclang-cpp.so.xx.y" not found.
## CMake things don't seem to work here because it is done with zig's
## build system. Also MAKE_ENV doesn't send the vars (esp.
## LD_LIBRARY_PATH) to zig build. So we need to prepend LD_LIBRARY_PATH
## in cmake/install.cmake (see post-configure target below)
MAKE_ENV+=	LD_LIBRARY_PATH=${LLVM_ISOLATED_PREFIX}/lib:/usr/pkg/lib:/usr/lib
MAKE_ENV+=	LDFLAGS=-Wl,-R${LLVM_ISOLATED_PREFIX}/lib
MAKE_ENV+=	LDFLAGS=-L/usr/pkg/lib

## Print every CMake command being run (for debugging/troubleshooting)
MAKE_ENV+=	VERBOSE=1

MAKE_ENV+=	ZIG_GLOBAL_CACHE_DIR=${WRKDIR}/${PACKAGE_SLUG}-global-cache
MAKE_ENV+=	ZIG_LOCAL_CACHE_DIR=${WRKDIR}/${PACKAGE_SLUG}-local-cache

CHECK_PORTABILITY_SKIP+=	ci/azure/macos_script
BUILDLINK_TRANSFORM+=		rm:-Werror

UNLIMIT_RESOURCES=	stacksize

# again, sigh...
RELRO_SUPPORTED=	no
MKPIE_SUPPORTED=	no
# TODO: /usr/bin/env + /bin/env in lib/std/zig/system.zig

pre-configure:
	## - Make zig build see LD_LIBRARY_PATH (e.g. path to
	## "libclang-cpp.so.xx.y")
	## - Set version string (esp. for dev builds)
	## - Make stage3 zig build process (build.zig) see the path
	## - Append or set CMake values (previously CMakeCache.txt
	##   "workaround"; starting from "CMAKE_INSTALL_PREFIX" line)
	${SED} -i'_orig' \
		-e '1{h;s,.*,set(ENV{LD_LIBRARY_PATH} "'${LLVM_ISOLATED_PREFIX}'/lib:/usr/pkg/lib:/usr/lib:$$\ENV{LD_LIBRARY_PATH}")\n,;G;}' \
		-e '1{h;s,.*,set(ENV{LIBRARY_PATH} "'${LLVM_ISOLATED_PREFIX}'/lib:/usr/pkg/lib:/usr/lib:$$\ENV{LIBRARY_PATH}")\n,;G;}' \
		-e '1{h;s,.*,set(ENV{LDFLAGS} "-Wl\,-R'${LLVM_ISOLATED_PREFIX}'/lib -L'${LLVM_ISOLATED_PREFIX}'/lib $$\ENV{LDFLAGS}")\n,;G;}' \
		-e '/set(ZIG_VERSION/ s,set(ZIG_VERSION "",set(ZIG_VERSION "${DISTNAME:S/zig-//}",' \
		-e '/$${CMAKE_PREFIX_PATH}/ s,^,list(APPEND ZIG_CMAKE_PREFIX_PATH "${LLVM_ISOLATED_PREFIX}")\n,' \
		-e '1{h;s,.*,set(CMAKE_INSTALL_PREFIX "${PREFIX}/${PACKAGE_SLUG}" CACHE PATH "Directory to install zig to" FORCE)\n,;G;}' \
		-e '$$s,$$,\nstring(APPEND CMAKE_CXX_FLAGS " -I${LLVM_ISOLATED_PREFIX}/include"),' \
		-e '$$s,$$,\nstring(APPEND CMAKE_CXX_LINK_FLAGS " -L${LLVM_ISOLATED_PREFIX}/lib -Wl\,-R${LLVM_ISOLATED_PREFIX}/lib"),' \
		-e '$$s,$$,\nstring(APPEND CMAKE_C_FLAGS " -I${LLVM_ISOLATED_PREFIX}/include"),' \
		-e '$$s,$$,\nstring(APPEND CMAKE_EXE_LINKER_FLAGS " -L${LLVM_ISOLATED_PREFIX}/lib -Wl\,-R${LLVM_ISOLATED_PREFIX}/lib"),' \
		-e '$$s,$$,\nstring(APPEND CMAKE_MODULE_LINKER_FLAGS " -L${LLVM_ISOLATED_PREFIX}/lib -Wl\,-R${LLVM_ISOLATED_PREFIX}/lib"),' \
		-e '$$s,$$,\nstring(APPEND CMAKE_SHARED_LINKER_FLAGS " -L${LLVM_ISOLATED_PREFIX}/lib -Wl\,-R${LLVM_ISOLATED_PREFIX}/lib"),' \
		-e '1{h;s,.*,set(CMAKE_INSTALL_RPATH "${LLVM_ISOLATED_PREFIX}/lib" CACHE PATH "" FORCE)\n,;G;}' \
		-e '1{h;s,.*,set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON CACHE BOOL "" FORCE)\n,;G;}' \
		${WRKDIR}/${DISTNAME}/CMakeLists.txt
	## Fix paths when lang/clang is already installed on system
	${SED} -i'_orig' \
		-e '1{h;s,.*,set(LLVM_INCLUDE_DIRS "'${LLVM_ISOLATED_PREFIX}'/include:$$\{LLVM_INCLUDE_DIRS}")\n,;G;}' \
		-e '1{h;s,.*,set(LLVM_LIBDIRS "'${LLVM_ISOLATED_PREFIX}'/lib:$$\{LLVM_LIBDIRS}")\n,;G;}' \
		-e '1{h;s,.*,set(CMAKE_PREFIX_PATH "'${LLVM_ISOLATED_PREFIX}'")\n,;G;}' \
		${WRKDIR}/${DISTNAME}/cmake/Findclang.cmake

post-configure:
	## Hardcode the path so that executing the linked
	## /usr/pkg/bin/${PACKAGE_SLUG} file doesn't say "unable to find zig
	## installation directory"
	${SED} -i'_orig' -e 's,= self_exe_path;,= "/usr/pkg/${PACKAGE_SLUG}/bin";\n    _ = self_exe_path;,' ${WRKDIR}/${DISTNAME}/src/introspect.zig

post-install:
	## Binary link for isolated install
	${MKDIR} -p ${DESTDIR}${PREFIX}/bin
	${LN} -sf ${PREFIX}/${PACKAGE_SLUG}/bin/zig ${DESTDIR}${PREFIX}/bin/${PACKAGE_SLUG}

# after install, because the zig binary ends up in paths like
# ./zig-0.10.1/zig-cache/o/e6445b80597d6bc8fe865e7254800ac9/zig
# unless we want to run find for the executable here?
do-test:
	mkdir ${WRKDIR}/cache
	cd ${WRKSRC} && \
		${DESTDIR}${PREFIX}/bin/${PACKAGE_SLUG} build test-behavior \
		--cache-dir ${WRKDIR}/cache --global-cache-dir ${WRKDIR}/cache \
		--zig-lib-dir ${WRKSRC}/lib

.include "../../devel/cmake/build.mk"
.include "../../devel/lld${REQUIRED_LLVM_MAJOR_VERSION}/buildlink3.mk"
.include "../../lang/clang${REQUIRED_LLVM_MAJOR_VERSION}/buildlink3.mk"
.include "../../lang/llvm${REQUIRED_LLVM_MAJOR_VERSION}/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
