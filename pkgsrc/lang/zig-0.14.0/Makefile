# $NetBSD: Makefile,v 1.42 2024/08/10 10:19:01 nia Exp $

## Update DISTNAME according to the latest master download URL and run
## "make makesum" after that.
## Example: If the URL is:
## https://ziglang.org/builds/zig-0.14.0-dev.3462+edabcf619.tar.xz
## then this value would be: zig-0.14.0-dev.3462+edabcf619
## Meaning, filename minus the .tar.xz extension
DISTNAME=	zig-0.14.0
## To make this a separate package than lang/zig
PKGNAME=	${DISTNAME:S/zig-/zig-isolated-/}
CATEGORIES=	lang
## https://ziglang.org/builds/ is the official
MASTER_SITES=	https://ziglang.org/builds/
## Alternate mirror
#MASTER_SITES=	https://zig.linus.dev/zig/
EXTRACT_SUFX=	.tar.xz
## Used mainly for /usr/pkg/xx directory and binary shortcut name.
## e.g. If this is "zig-0.14.0" zig will be installed in
## /usr/pkg/zig-0.14.0, zig is available as /usr/pkg/bin/zig-0.14.0 and
## can be used by running "zig-0.14.0".
PACKAGE_SLUG=	zig-${PKGVERSION_NOREV}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	https://ziglang.org/
COMMENT=	Programming language designed for robustness and clarity
LICENSE=	mit

# Fails to build in chroot on netbsd: https://github.com/ziglang/zig/issues/19756
USE_CXX_FEATURES+=	c++17
USE_LANGUAGES=		c c++
USE_TOOLS+=		bash:run

CMAKE_CONFIGURE_ARGS+=	-DCMAKE_BUILD_TYPE=Release
CMAKE_CONFIGURE_ARGS+=	-DZIG_SHARED_LLVM=ON
## Seperate prefix (may not work, needs post-configure target below)
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_INSTALL_PREFIX=${DESTDIR}${PREFIX}/${PACKAGE_SLUG}
# avoid full-cu-features available to build host,
# in other words ensure that we run everywhere
CMAKE_CONFIGURE_ARGS+=	-DZIG_TARGET_MCPU=baseline
#CMAKE_CONFIGURE_ARGS+=	-DZIG_PIE=ON

## Make it see files from the path of lang/llvm19
.include "../../lang/llvm19/isolatedversion.mk"
LDFLAGS+=		-L${LLVM_ISOLATED_PREFIX}/lib -Wl,-R${LLVM_ISOLATED_PREFIX}/lib
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_CXX_LINK_FLAGS=${LDFLAGS:Q}
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_C_LINK_FLAGS=${LDFLAGS:Q}
## Because zig build can't find libxml etc. if not set to /usr/pkg
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_PREFIX_PATH=${PREFIX}
## Print every CMake command being run (for debugging/troubleshooting)
MAKE_ENV+=	VERBOSE=1
## Fix for "libclang-cpp.so.xx.y" not found.
## CMake things don't seem to work here because it is done with zig's
## build system. Also MAKE_ENV doesn't send the vars (esp.
## LD_LIBRARY_PATH) to zig build. So we need to prepend LD_LIBRARY_PATH
## in cmake/install.cmake (see post-configure target below)
MAKE_ENV+=	LD_LIBRARY_PATH=${LLVM_ISOLATED_PREFIX}/lib:/usr/pkg/lib:/usr/lib
MAKE_ENV+=	LDFLAGS=-Wl,-R${LLVM_ISOLATED_PREFIX}/lib
MAKE_ENV+=	LDFLAGS=-L/usr/pkg/lib

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
	## Make zig build see LD_LIBRARY_PATH (e.g. path to
	## "libclang-cpp.so.xx.y")
	${SED} -i'_orig' \
		-e '1{h;s,.*,set(ENV{LD_LIBRARY_PATH} "'${LLVM_ISOLATED_PREFIX}'/lib:/usr/pkg/lib:/usr/lib:$$\ENV{LD_LIBRARY_PATH}")\n,;G;}' \
		-e '1{h;s,.*,set(ENV{LIBRARY_PATH} "'${LLVM_ISOLATED_PREFIX}'/lib:/usr/pkg/lib:/usr/lib:$$\ENV{LIBRARY_PATH}")\n,;G;}' \
		-e '1{h;s,.*,set(ENV{LDFLAGS} "-Wl\,-R'${LLVM_ISOLATED_PREFIX}'/lib -L'${LLVM_ISOLATED_PREFIX}'/lib $$\ENV{LDFLAGS}")\n,;G;}' \
		${WRKDIR}/${DISTNAME}/CMakeLists.txt
	## Fix paths when lang/clang is already installed on system
	${SED} -i'_orig' \
		-e '1{h;s,.*,set(LLVM_INCLUDE_DIRS "'${LLVM_ISOLATED_PREFIX}'/include:$$\{LLVM_INCLUDE_DIRS}")\n,;G;}' \
		-e '1{h;s,.*,set(LLVM_LIBDIRS "'${LLVM_ISOLATED_PREFIX}'/lib:$$\{LLVM_LIBDIRS}")\n,;G;}' \
		-e '1{h;s,.*,set(CMAKE_PREFIX_PATH "'${LLVM_ISOLATED_PREFIX}'")\n,;G;}' \
		${WRKDIR}/${DISTNAME}/cmake/Findclang.cmake
	## Make stage3 zig build process (build.zig) see the path
	${SED} -i'_orig' -e '/$${CMAKE_PREFIX_PATH}/ s,^,list(APPEND ZIG_CMAKE_PREFIX_PATH "${LLVM_ISOLATED_PREFIX}")\n,' ${WRKDIR}/${DISTNAME}/CMakeLists.txt

post-configure:
	## Workaround for making CMake see the isolated prefix
	${FIND} ${WRKSRC} -name CMakeCache\.txt -exec sed -i'_orig' \
		-e 's,^CMAKE_INSTALL_PREFIX:PATH=.*,CMAKE_INSTALL_PREFIX:PATH='${PREFIX}/${PACKAGE_SLUG}',' \
		-e '/^CMAKE_CXX_FLAGS:/ s,$$, -I'${LLVM_ISOLATED_PREFIX}'/include,' \
		-e '/^CMAKE_CXX_LINK_FLAGS:/ s,$$, -L'${LLVM_ISOLATED_PREFIX}'/lib -Wl\,-R'${LLVM_ISOLATED_PREFIX}'/lib,' \
		-e '/^CMAKE_C_FLAGS:/ s,$$, -I'${LLVM_ISOLATED_PREFIX}'/include,' \
		-e '/^CMAKE_EXE_LINKER_FLAGS:/ s,$$, -L'${LLVM_ISOLATED_PREFIX}'/lib -Wl\,-R'${LLVM_ISOLATED_PREFIX}'/lib,' \
		-e '/^CMAKE_MODULE_LINKER_FLAGS:/ s,$$, -L'${LLVM_ISOLATED_PREFIX}'/lib -Wl\,-R'${LLVM_ISOLATED_PREFIX}'/lib,' \
		-e '/^CMAKE_SHARED_LINKER_FLAGS:/ s,$$, -L'${LLVM_ISOLATED_PREFIX}'/lib -Wl\,-R'${LLVM_ISOLATED_PREFIX}'/lib,' \
		-e '$$s,$$,\nCMAKE_INSTALL_RPATH:PATH='${LLVM_ISOLATED_PREFIX}'/lib,' \
		-e '$$s,$$,\nCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=ON,' \
		{} \;
		#-e '/^CMAKE_PREFIX_PATH:/ s,=.*,=${LLVM_ISOLATED_PREFIX},' \
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
.include "../../devel/lld19/buildlink3.mk"
.include "../../lang/clang19/buildlink3.mk"
.include "../../lang/llvm19/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
