# $NetBSD: Makefile,v 1.4 2024/08/13 19:41:04 wiz Exp $

DISTNAME=	master
CATEGORIES=	devel
## If you get checksum error, run "make makesum" first.
MASTER_SITES=	https://github.com/zigtools/zls/archive/refs/heads/
EXTRACT_SUFX=	.zip

## "0.15.0-dev" part is taken from ".version" line on build.zig.zon
## Please update if necessary.
PKGNAME=	zls-master-0.15.0-dev

## zls master archive extracts in a different dir
WRKSRC=		${WRKDIR}/zls-master

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
	${LN} -sf ${ZIG_PREFIX}/bin/zls ${DESTDIR}${PREFIX}/bin/zls-master

.include "zig-depends.mk"
.include "../../lang/zig-master/application.mk"
.include "../../mk/bsd.pkg.mk"
