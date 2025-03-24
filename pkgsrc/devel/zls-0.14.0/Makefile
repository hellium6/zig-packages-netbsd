# $NetBSD: Makefile,v 1.4 2024/08/13 19:41:04 wiz Exp $

DISTNAME=	zls-0.14.0
CATEGORIES=	devel
MASTER_SITES=	${MASTER_SITE_GITHUB:=zigtools/}
GITHUB_PROJECT=	zls
GITHUB_TAG=	${PKGVERSION_NOREV}

## We prepare a version suffix code to make the name unique.
## Allows to install this package with devel/zls in same system.
APPEND_VER=	${DISTNAME:S/zls-//:S/.//g}
PKGNAME=	${DISTNAME:S/zls-/zls-isolated${APPEND_VER}-/}

COMMENT=	Language Server for zig (prefix isolated)
MAINTAINER=	nikita@NetBSD.org
HOMEPAGE=	https://github.com/zigtools/zls/
LICENSE=	mit

ZIGSTRIP=	no

# Temporary required, a zig build system parser is being written.
ALLOW_NETWORK_ACCESS=yes

post-install:
	## Binary link for isolated install
	${MKDIR} -p ${DESTDIR}${PREFIX}/bin
	${LN} -sf ${ZIG_PREFIX}/bin/zls ${DESTDIR}${PREFIX}/bin/zls-${PKGVERSION_NOREV}

.include "zig-depends.mk"
.include "../../lang/zig-0.14.0/application.mk"
.include "../../mk/bsd.pkg.mk"
