# NetBSD pkgsrc packages for building Zig 0.14.0 master

This is prepared at the beginning of February 2025 when LLVM 19.x is still not available in NetBSD 10.0 repos. So I had to prepare these packages to build Zig 0.14 dev version (master).

Using this repo might break your system or do unexpected things to packages collection. Keeping a backup is recommended before installing any package from sources. If you find any issues, post an issue.

## Check

- In case you reached here, first check if llvm 19.x is available in NetBSD repos by running `pkgin se llvm`. If it is available then use it instead, then continue with zig build.
- Run `pkgin se zig` to see if Zig 0.14 is available in NetBSD repos. If it is available then probably it is not necessary to use this repo at all.
- If you know what you're doing, it is up to you.

## Usage

- [Populate `/usr/pkgsrc`](https://www.netbsd.org/docs/pkgsrc/getting.html)
- Optionally `chown -R yournonrootuser:group /usr/pkgsrc` so that editing files is easier
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
## put the fetched value in DISTNAME
sed -i -e "s/^DISTNAME=.*/DISTNAME=	$ZIGF/" Makefile
## or enter manually
#sed -i -e 's/^DISTNAME=.*/DISTNAME=	zig-0.14.0-dev.3046+08d661fcf/' Makefile
## optionally change MASTER_SITES to use a mirror
sed -i -e 's/^MASTER_SITES=.*/MASTER_SITES=	https:\/\/zig.linus.dev\/zig\//' Makefile
make makesum  # update checksums according to new DISTNAME
make install
```

If it complains about some files not existing or not listed in PLIST etc. this usually takes care of it:

```
make print-PLIST > PLIST
make install-clean
make install
```

Alternatively package files can be generated and installed by running this instead of `make install`:

```sh
make package
doas pkg_add /usr/pkgsrc/packages/All/package-filename-here.tgz
```

Creating package files lets you keep a backup of them for future installations without building them again.

Example output after install:

```sh
$ llvm-config --version
19.1.7
$ ld.lld --version
LLD 19.1.7 (compatible with GNU linkers)
$ clang --version
clang version 19.1.7
Target: x86_64-unknown-netbsd10.0
Thread model: posix
InstalledDir: /usr/pkg/bin
$ zig version
0.14.0
```

License: Anything added by me in this repo (not what is based on another project) is public domain or CC0 1.0 Universal. For things taken from other projects, refer to those projects, such as [pkgsrc](https://github.com/NetBSD/pkgsrc).
