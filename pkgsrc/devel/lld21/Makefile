# $NetBSD: Makefile,v 1.26 2024/08/25 06:18:36 wiz Exp $

.include "../../lang/llvm21/version.mk"

DISTNAME=	lld-${LLVM_VERSION}.src
## So that this devel/lldXX package can live with devel/lld package
PKGNAME=	lld${LLVM_MAJOR_VERSION}-${LLVM_VERSION}
CATEGORIES=	devel

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	https://lld.llvm.org/
COMMENT=	The LLVM Linker
LICENSE=	apache-2.0

USE_CXX_FEATURES=	c++14
USE_LANGUAGES=		c c++
GCC_REQD+=		7

CMAKE_CONFIGURE_ARGS+=	-DCMAKE_BUILD_TYPE=Release
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_C_COMPILER=${CC:Q}
CMAKE_CONFIGURE_ARGS+=	-DCMAKE_CXX_COMPILER=${CXX:Q}

PYTHON_FOR_BUILD_ONLY=	yes

INSTALLATION_DIRS+=	libexec/lld

post-configure:
	## Workaround to make CMake see the paths
	${FIND} ${WRKSRC} -name CMakeCache\.txt -exec sed -i'_orig' \
		-e 's,^CMAKE_INSTALL_PREFIX:PATH=/usr/pkg,CMAKE_INSTALL_PREFIX:PATH='${LLVM_ISOLATED_PREFIX}',' \
		{} \;

post-install:
	## We make binaries available as binnameXX so that it doesn't
	## conflict with devel/lld files
	${LN} -sf ${LLVM_ISOLATED_PREFIX_BASENAME}/bin/lld ${DESTDIR}${PREFIX}/libexec/lld/ld${LLVM_MAJOR_VERSION}

	${MKDIR} -p ${DESTDIR}${PREFIX}/bin
	${FIND} ${DESTDIR}${LLVM_ISOLATED_PREFIX}/bin -mindepth 1 -execdir \
		${LN} -vsf ${LLVM_ISOLATED_PREFIX}/bin/{} ${DESTDIR}${PREFIX}/bin/{}${LLVM_MAJOR_VERSION} \;

.include "options.mk"
.include "../../devel/cmake/build.mk"
.include "../../lang/llvm21/buildlink3.mk"
.include "../../lang/libunwind/buildlink3.mk"
.include "../../lang/python/tool.mk"
.include "../../mk/atomic64.mk"
.include "../../mk/bsd.pkg.mk"
