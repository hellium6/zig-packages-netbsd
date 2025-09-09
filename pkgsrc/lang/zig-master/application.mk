# $NetBSD: application.mk,v 1.10 2024/04/29 13:22:43 nikita Exp $
#
# Common logic to handle zig packages
# This is only usable if they include a 'build.zig' file
#
.include "../../mk/bsd.fast.prefs.mk"

# https://github.com/ziglang/zig/issues/3382
# For now, Zig doesn't support CFLAGS/LDFLAGS/etc.

# Debug build (default):
# Fast compilation speed, Safety checks enabled, Slow runtime performance
# Large binary size, No reproducible build requirement
# ReleaseFast (-Drelease-fast)
# Fast runtime performance, Safety checks disabled, Slow compilation speed
# Large binary size, Reproducible build
# ReleaseSafe (-Drelease-safe=true)
# Medium runtime performance, Safety checks enabled, Slow compilation speed
# Large binary size, Reproducible build
# ReleaseSmall (-Drelease-small=true)
# Medium runtime performance, Safety checks disabled, Slow compilation speed
# Small binary size
ZIGBUILDMODE?=		--release=safe
ZIGCPUMODE?=		-Dcpu=baseline
ZIGBUILDARGS?=
ZIGTESTARGS?=
ZIGPIE?=		yes
ZIGSTRIP?=		yes

TOOL_DEPENDS+=		zig-master-[0-9]*:../../lang/zig-master
USE_LANGUAGES=		c

## CHANGE PACKAGE_SLUG according to the value in lang/zig-master/Makefile.
PACKAGE_SLUG=	zig-master
ZIG_BINARY=	${PREFIX}/bin/${PACKAGE_SLUG}
ZIG_PREFIX=	${PREFIX}/${PACKAGE_SLUG}

MAKE_ENV+=	ZIG_GLOBAL_CACHE_DIR=${WRKDIR}/${PACKAGE_SLUG}-global-cache
MAKE_ENV+=	ZIG_LOCAL_CACHE_DIR=${WRKDIR}/${PACKAGE_SLUG}-local-cache

.if ${ZIGPIE:Uyes:M[yY][eE][sS]}
ZIGBUILDARGS+=		-Dpie=true
.endif

.if ${ZIGSTRIP:Uyes:M[yY][eE][sS]}
.  if ${MKDEBUG:Uyes:M[yY][eE][sS]} && ${INSTALL_UNSTRIPPED:Uyes:tl} == yes
ZIGBUILDARGS+=		-Dstrip=true
.  endif
.endif

# TODO: save to distfiles. zig fetch is distributed not centralized to github.com
# DISTFILES?=			${DEFAULT_DISTFILES}
# .for pkg in ${ZIG_PACKAGE_DEPENDS}
# DIST_SUBDIR=			${PKGNAME}
# DISTFILES+=			${pkg}
# SITES.${pkg}+=			-${pkg}
# .endfor

.PHONY: print-zig-depends
print-zig-depends:
	${RUN}${AWK} 'BEGIN {print "# $$Net" "BSD$$"; print;} \
                /url = / { split($$0, a, "\""); url=a[2]; print "ZIG_PACKAGE_DEPENDS+=\t" url; }' \
		${WRKSRC}/build.zig.zon

post-extract: zig-vendor-packages
.PHONY: zig-vendor-packages
zig-vendor-packages:
.for pkg in ${ZIG_PACKAGE_DEPENDS}
	${RUN} ${ZIG_BINARY} fetch --global-cache-dir ${WRKDIR}/zig-master-global-cache ${pkg}
.endfor


do-build:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${ZIG_BINARY} build ${ZIGBUILDMODE} ${ZIGCPUMODE} ${ZIGBUILDARGS} --prefix ${DESTDIR}${ZIG_PREFIX}

do-install:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${ZIG_BINARY} build install ${ZIGBUILDMODE} ${ZIGCPUMODE} ${ZIGBUILDARGS} --prefix ${DESTDIR}${ZIG_PREFIX}

do-test:
	cd ${WRKSRC} && ${SETENV} ${TEST_ENV} ${ZIG_BINARY} build ${ZIGBUILDMODE} ${ZIGBUILDARGS} ${ZIGCPUMODE} ${ZIGTESTARGS} test
