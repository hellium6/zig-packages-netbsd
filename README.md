# Zig master for NetBSD

`pkgsrc` packages to run Zig master on NetBSD. Tested on NetBSD 10.0.

> /!\ WARNING: This repo deals with bleeding edge software that might affect the stability of your system.
> 
> Avoid using this repo if it is not absolutely necessary. This is meant for tinkerers. There is no guarantee of any kind that this will work perfectly. Using this repo might break your system or do unexpected things to packages collection. You have been warned. Keeping a backup is recommended before installing any package from sources. If you find any issues, please post an issue.

If you are ok with slightly outdated versions, then the version available on the NetBSD official repos might be adequate for you and this repo might not be necessary.

However, if you know what you are doing, the choice is yours.

## History

This was prepared at the beginning of February 2025 when LLVM 19.x was needed to build Zig 0.14.0 dev version (master) which was still not available in NetBSD 10.0 repos at that time. So I had to prepare these packages. I didn't even use different names for the packages. So official packages of zig and llvm family of packages would have to be uninstalled or replaced.

This has changed since then. Packages in this repo should be able to live with official packages without file conflicts.

This repo now uses packages with different names than NetBSD official repos. This allows packages of this repo to live with official `llvm`, `clang`, `lld` and `zig` packages. e.g. You can have Zig stable and Zig master on the same system now. This is good for testing code in both I suppose. If you want the old behavior, meaning keeping the original package names (which is discouraged), check the `v20250207` release or tag.

Packages here are named differently and installed in different directories. e.g. The package `lang/llvm19` installs files in `/usr/pkg/llvm19` and links executables to `/usr/pkg/bin` with LLVM version suffixed, like `llvm-config19`, `llvm-link19` etc. So `llvm-config` would be from `lang/llvm` and `llvm-config19` would be from `lang/llvm19` of this repo. This style is somewhat akin to [FreeBSD's `lang/llvm19` port](https://www.freshports.org/devel/llvm19/).

## Check

In case you reached here check the following:

- Run `pkgin se zig` to see if the Zig version you want (e.g. 0.14.0) is available in NetBSD official repos. If it is available then probably it is not necessary to use this repo at all.
- If you want to skip building, you might [find releases](https://github.com/hellium6/zig-master-netbsd/releases) with binary packages which you can install in this order - llvm, lld, clang, zig-master - with something like: `doas pkg_add /path/to/some-package.tgz`
- If you want to build from source, follow the instructions below.
- Building from source might require some hours or days (depending on your hardware) to finish as some packages have big codebases. Megabytes of sources producing gigabytes of outputs.
- [There are](https://github.com/NetBSD/pkgsrc/issues/155) WIP LLVM packages (<https://pkgsrc.se/wip/llvm>, <https://pkgsrc.se/wip/lld>, <https://pkgsrc.se/wip/clang>). I haven't tried them but I expect them to be better than mine. But the `zig-master` package in this repo doesn't use them. If you want to use them you might have to make some edits. e.g. Replacing `lang/llvm19` with `wip/llvm`, `devel/lld19` with `wip/lld` etc. And I'm not sure if you'd be able to have anything LLVM 18.x based on the system.

## Usage

- [Populate `/usr/pkgsrc`](https://www.netbsd.org/docs/pkgsrc/getting.html)
- Optionally `chown -R yournonrootusername:users /usr/pkgsrc` so that editing files is easier
- Then:

```sh
cp -r pkgsrc/* /usr/pkgsrc/

cd /usr/pkgsrc/lang/llvm19
make install

cd /usr/pkgsrc/devel/lld19
make install

cd /usr/pkgsrc/lang/clang19
make install

cd /usr/pkgsrc/lang/zig-master
## update DISTNAME in Makefile according to download URL
## read comment in the file for details
## to get latest master or dev download:
ZIGF=$(curl -s https://ziglang.org/download/ | grep '\-dev' | head -n1 | sed -ne 's|.*>\(zig.*\)\.tar\.xz<\/a.*|\1|p')
## put the fetched value in previous command as DISTNAME
sed -i -e "s/^DISTNAME=.*/DISTNAME=	$ZIGF/" Makefile
## or enter manually
#sed -i -e 's/^DISTNAME=.*/DISTNAME=	zig-0.14.0-dev.3222+8a3aebaee/' Makefile
## optionally change MASTER_SITES to use a mirror
sed -i -e 's/^MASTER_SITES=.*/MASTER_SITES=	https:\/\/zig.linus.dev\/zig\//' Makefile
make makesum  # update checksums according to new DISTNAME
make install
```

If it complains about some files not existing or not listed in PLIST etc. this usually takes care of it:

```sh
make print-PLIST > PLIST
make install-clean
make install
```

If you already have the package installed, you might have to do `make update` or `make replace` instead of `make install` in above commands. [Check here](https://www.netbsd.org/docs/pkgsrc/build.html#build.helpful-targets) for more info on which one to use when.

Alternatively package files can be generated and installed by running this instead of `make install`:

```sh
make package  # or make repackage
doas pkg_add /usr/pkgsrc/packages/All/package-filename-here.tgz
```

Creating package files lets you keep a backup of them for future installations without building them again.

Example output after install:

```sh
$ llvm-config19 --version
19.1.7
$ /usr/pkg/llvm19/bin/ld.lld --version
LLD 19.1.7 (compatible with GNU linkers)
$ clang++19 --version
clang version 19.1.7
Target: x86_64-unknown-netbsd10.0
Thread model: posix
InstalledDir: /usr/pkg/llvm19/bin
$ zig-master version
0.14.0
$ pkg_info -a | grep ^zig
zig-master-0.14.0-dev.3267+59dc15fa0 Programming language designed for robustness and clarity
```

Example of working with both Zig and Zig master on the same system:

```sh
$ echo $SHELL
/usr/pkg/bin/bash
$ doas pkgin in zig
$ zig version
0.13.0
$ zig-master version
0.14.0
### typing zig-master every time is boring, so...
$ alias zig=zig-master
### above can be added in ~/.bashrc to do this automatically on startup
$ zig version
0.14.0
$ cd `mktemp -d`
$ zig init
info: created build.zig
info: created build.zig.zon
info: created src/main.zig
info: created src/root.zig
info: see `zig build --help` for a menu of options
$ zig build
### easy to undo...
$ unalias zig
$ zig version
0.13.0
```

Example of uninstalling a package:

```sh
$ pkg_info -a | grep ^zig
zig-master-0.14.0-dev.3267+59dc15fa0 Programming language designed for robustness and clarity
$ doas pkg_delete zig-master-0.14.0-dev.3267+59dc15fa0
```

License: Anything added by me in this repo (not what is based on another project) is public domain or CC0 1.0 Universal. For things taken from other projects, refer to those projects, such as [pkgsrc](https://github.com/NetBSD/pkgsrc).
