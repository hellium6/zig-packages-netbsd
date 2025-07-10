# $NetBSD: $
## This file is for non-llvm packages. Using version.mk as it is in
## non-llvm packages changes mastersite and other variables which causes
## issues with DISTFILE. e.g. lang/zig-master.

## TODO: Make it so that setting var values in one place is enough

## Different prefix to allow lang/llvmXX to live with lang/llvm
LLVM_VERSION?=	20.1.6
LLVM_MAJOR_VERSION?=	${LLVM_VERSION:tu:C/\\.[[:digit:]\.]*//}
LLVM_ISOLATED_PREFIX_BASENAME=	llvm${LLVM_MAJOR_VERSION}
LLVM_ISOLATED_PREFIX=			${PREFIX}/${LLVM_ISOLATED_PREFIX_BASENAME}
