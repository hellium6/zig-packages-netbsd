# $NetBSD: version.mk,v 1.17 2024/07/06 15:45:06 adam Exp $
# used by devel/lld
# used by devel/lldb
# used by devel/polly
# used by lang/clang
# used by lang/clang-tools-extra
# used by lang/compiler-rt
# used by lang/flang
# used by lang/libcxx
# used by lang/libcxxabi
# used by lang/libunwind
# used by lang/mlir
# used by lang/wasi-compiler-rt
# used by lang/wasi-libcxx
# used by parallel/openmp

## Also change LLVM_VERSION in isolatedversion.mk
LLVM_VERSION=	22.1.8
DISTNAME=	llvm-project-${LLVM_VERSION}.src
MASTER_SITES=	${MASTER_SITE_GITHUB:=llvm/}
GITHUB_PROJECT=	llvm-project
GITHUB_RELEASE=	llvmorg-${PKGVERSION_NOREV}
EXTRACT_SUFX=	.tar.xz

## :C strips version number from ${PKGBASE}
## So "llvm22" becomes "llvm" for example
WRKSRC=		${WRKDIR}/${DISTNAME}/${PKGBASE:C/..$$//:S/wasi-//}

LLVM_MAJOR_VERSION=	${LLVM_VERSION:tu:C/\\.[[:digit:]\.]*//}

## Different prefix to allow lang/llvmXX to live with lang/llvm
LLVM_ISOLATED_PREFIX_BASENAME=	llvm${LLVM_MAJOR_VERSION}
LLVM_ISOLATED_PREFIX=			${PREFIX}/${LLVM_ISOLATED_PREFIX_BASENAME}

EXTRACT_ELEMENTS=	${DISTNAME}/${PKGBASE:C/..$$//:S/wasi-//}
EXTRACT_ELEMENTS+=	${DISTNAME}/cmake
EXTRACT_ELEMENTS+=	${DISTNAME}/runtimes
