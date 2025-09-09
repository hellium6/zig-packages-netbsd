# Zig master for NetBSD

`pkgsrc` packages to run Zig master on NetBSD. Tested on NetBSD 10.1.

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

- Run `pkgin se zig` to see if the Zig version you want (e.g. 0.15.0) is available in NetBSD official repos. If it is available then probably it is not necessary to use this repo at all.
- If you want to skip building, you might [find releases](https://github.com/hellium6/zig-master-netbsd/releases) with binary packages which you can install in this order - llvm, lld, clang, zig-master - with something like: `doas pkg_add /path/to/some-package.tgz`
- If you want to build from source, follow the instructions below.
- Building from source might require some hours or days (depending on your hardware) to finish as some packages have big codebases. Megabytes of sources producing gigabytes of outputs.
- [There are](https://github.com/NetBSD/pkgsrc/issues/155) WIP LLVM packages (<https://pkgsrc.se/wip/llvm>, <https://pkgsrc.se/wip/lld>, <https://pkgsrc.se/wip/clang>). I haven't tried them but I expect them to be better than mine. But the Zig packages in this repo doesn't use them. If you want to use them you might have to make some edits. e.g. Replacing `lang/llvm19` with `wip/llvm`, `devel/lld19` with `wip/lld` etc. And I'm not sure if you'd be able to have anything LLVM 18.x based on the system.

## Usage

- [Populate `/usr/pkgsrc`](https://www.netbsd.org/docs/pkgsrc/getting.html)
- Optionally `chown -R yournonrootusername:users /usr/pkgsrc` so that editing files is easier
- Note the LLVM versions required for corresponding Zig versions:

```
zig-0.16.x: LLVM 21 (early builds might want 20)
zig-0.15.x: LLVM 20 (early builds might want 19)
zig-0.14.x: LLVM 19
zig-0.13.x: LLVM 18
```

- Then:

```sh
cp -r pkgsrc/* /usr/pkgsrc/

### For zig-master:
cd /usr/pkgsrc/lang/llvm21
make install

cd /usr/pkgsrc/devel/lld21
make install

cd /usr/pkgsrc/lang/clang21
make install

cd /usr/pkgsrc/lang/zig-master
### For 0.15.1 stable:
### Install lang/llvm20, devel/lld20, lang/clang20 like above, then:
### cd /usr/pkgsrc/lang/zig-0.15
### For 0.14.0 stable:
### Install lang/llvm19, devel/lld19, lang/clang19 like above, then:
### cd /usr/pkgsrc/lang/zig-0.14.0
### For 0.13.0 stable:
### Install lang/llvm18, devel/lld18, lang/clang18
### Then:
### cd /usr/pkgsrc/lang/zig-0.13.0

## update DISTNAME in Makefile according to download URL
## read comment in the file for details
## to get latest master or dev download:
ZIGF=$(curl -s https://ziglang.org/download/ | grep '\-dev' | head -n1 | sed -ne 's|.*>\(zig.*\)\.tar\.xz<\/a.*|\1|p')
## put the fetched value in previous command as DISTNAME
sed -i -e "s/^DISTNAME=.*/DISTNAME=	$ZIGF/" Makefile
## or enter manually
#sed -i -e 's/^DISTNAME=.*/DISTNAME=	zig-0.16.0-dev.191+9fa2394f8/' Makefile
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

Alternatively to generate package files but not install it, run this instead of `make install`:

```sh
make package  # or make repackage
```

You can keep a backup of the generated package files in `/usr/pkgsrc/packages/` so that you can install them on future clean installs of NetBSD without building them again saving you lots of time. To install from package file:

```sh
doas pkg_add /usr/pkgsrc/packages/All/package-filename-here.tgz
## or
doas pkg_add /path/to/package-filename-here.tgz
```

Example output after install:

```sh
$ llvm-config21 --version
21.1.0
$ /usr/pkg/llvm21/bin/ld.lld --version
LLD 21.1.0 (compatible with GNU linkers)
$ clang++21 --version
clang version 21.1.0
Target: x86_64-unknown-netbsd10.1
Thread model: posix
InstalledDir: /usr/pkg/llvm21/bin
$ zig-master version
0.16.0-dev.205+4c0127566
$ pkg_info -a | grep ^zig
zig-master-0.16.0-dev.205+4c0127566 Programming language designed for robustness and clarity (prefix isolated)
```

Example of working with both Zig and Zig master on the same system:

```sh
$ echo $SHELL
/usr/pkg/bin/bash
$ doas pkgin in zig
$ zig version
0.14.1
$ zig-master version
0.16.0-dev.205+4c0127566
### For lang/zig-0.14.0 you'd have to run zig-0.14.0 or
### if you've changed DISTNAME, type "zig" and press tab twice for hint.
### Example:
### $ zig-0.14.0-dev.3462 version
### 0.14.0-dev.3462+edabcf619
### This is similar to lang/zig-0.13.0

### typing zig-master every time is boring, so...
$ alias zig=zig-master
### above can be added in ~/.bashrc to do this automatically on startup
$ zig version
0.16.0-dev.205+4c0127566
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
zig-master-0.16.0-dev.205+4c0127566 Programming language designed for robustness and clarity
### For lang/zig-0.15 the output might be something like:
### zig-master-0.15.0-dev.300+9e21ba12d Programming language designed for robustness and clarity (prefix isolated)
### For lang/zig-0.14.0 the output might be something like:
### zig-isolated0140-0.14.0 Programming language designed for robustness and clarity (prefix isolated)
### Output should be similar for older versions
### To continue with uninstalling
$ doas pkg_delete zig-master-0.16.0-dev.205+4c0127566
```

### ZLS

If you want to use [Zig Language Server (ZLS)](https://github.com/zigtools/zls/) for [text editor autocomplete and other features](https://langserver.org/), you'd preferably need the zls version matching your installed Zig version.

Multiple versions of zls can live in the same NetBSD system. e.g. You can keep `devel/zls` from official pkgsrc, `devel/zls-master` and `devel/zls-0.14.0` together. Just make sure to use the appropriate binary path in the configuration of the text editor.

Installation:

```sh
### For zig-master you need devel/zls-master
$ cd /usr/pkgsrc/devel/zls-master
$ make makesum  # update checksum according to latest master archive
$ make install
$ zls-master --version
0.16.0-dev
$ which zls-master
/usr/pkg/bin/zls-master
### Use the above path in your text editor config to use this zls

### For zig-0.14.0 (dev or stable) you need devel/zls-0.14.0
$ cd /usr/pkgsrc/devel/zls-0.14.0
$ make install
$ zls-0.14.0 --version
0.14.0
$ which zls-0.14.0
/usr/pkg/bin/zls-0.14.0
### Use the above path in your text editor config to use this zls

### For zig-0.13.0 (dev or stable) you need devel/zls-0.13.0
### Just use the instructions for 0.14.0 above replacing it with 0.13.0
```

Configuration example with vim:

```sh
$ doas pkgin in vim
$ vim --version | head -1
VIM - Vi IMproved 9.1 (2024 Jan 02, compiled Feb 27 2025 03:36:34)

## install plugin
$ mkdir -p $HOME/.vim/pack/downloads/opt
$ cd $HOME/.vim/pack/downloads/opt
$ git clone https://github.com/yegappan/lsp
$ vim -u NONE -c "helptags $HOME/.vim/pack/downloads/opt/lsp/doc" -c q

$ echo 'packadd lsp' >> $HOME/.vimrc
```

Append below to `~/.vimrc` (don't forget to change `path` if needed):

```vim
" detect .zig files as zig code automatically
autocmd BufNewFile,BufRead *.zig set filetype=zig

" Zig language server
call LspAddServer([#{
        \    name: 'zls',
        \    filetype: ['zig'],
        \    path: '/usr/pkg/bin/zls-master',
        \    args: [],
        \  }])
```

To test:

```sh
$ echo 'const std = @import("std")' >> test.zig
$ vim test.zig
```

- Optionally, type `:LspShowAllServers` and enter to show status. It should show something like:

```
Filetype Information
====================
Filetype: 'zig'
Server Name: 'zls'
Server Path: '/usr/pkg/bin/zls-master'
Status: Running

Buffer Information
==================
Buffer: 'test.zig'
Server Path: '/usr/pkg/bin/zls-master'
```

`:q` to get back to buffer.

- To test definitions `fi` to get cursor over `@import`, `:LspHover` to show definition and information about `@import`. `<esc>` to hide.
- Buffer should show an `E>` on the left gutter of the line because there is no `;` at the end of the line (intentionally left out). Type `<shift>a;<esc>` to fix it.
- To try autocomplete suggestions, press `o` (lowercase letter O) to create new line, then try typing `std.d` and it should show options `debug` and `dwarf`. Press `<down><enter>` to select `debug`.
- To save and exit `:wq<enter>`

If you want to use this on Geany instead, [there is a way](https://github.com/hellium6/zig-master-netbsd/issues/15).

For other text editors, please refer to [this LSP clients list](https://langserver.org/#implementations-client).


License: Anything added by me in this repo (not what is based on another project) is public domain or CC0 1.0 Universal. For things taken from other projects, refer to those projects, such as [pkgsrc](https://github.com/NetBSD/pkgsrc).
