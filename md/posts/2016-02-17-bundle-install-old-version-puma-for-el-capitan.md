---
layout: post
title: "El Capitan上に古いpumaをインストールすると失敗する"
description: ""
category: 
tags: [Ruby, Mac]
old_url: http://d.hatena.ne.jp/kk_Ataka/20160217/1455714725
---

## あらすじ

El Capitan上に `bundle install` で古い `puma` を入れようとしたらエラーになった。

- [Need to specify `--with-opt-dir` on OSX 10.11 El Capitan. · Issue #718 · puma/puma](https://github.com/puma/puma/issues/718)

## 環境

- Mac OS X El Capitan 10.11.3
- Ruby 2.1.4p265

## 解決策

EL Capitanに古い `2.14` より低い `puma` を入れるには `--with-opt-dir` でopensslのパスを指定する必要がある。

```sh
$ bundle config build.puma --with-opt-dir=/usr/local/opt/openssl
```

```sh
$ cat ~/.bundle/config
---
BUNDLE_BUILD__PUMA: "--with-opt-dir=/usr/local/opt/openssl"
```

指定しないとエラー。

```sh
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

    /Users/ataka/.rbenv/versions/2.1.4/bin/ruby extconf.rb
checking for BIO_read() in -lcrypto... yes
checking for SSL_CTX_new() in -lssl... yes
creating Makefile

make "DESTDIR=" clean

make "DESTDIR="
compiling http11_parser.c
compiling io_buffer.c
io_buffer.c:119:21: warning: passing 'uint8_t *' (aka 'unsigned char *') to parameter of type 'const char *' converts between pointers to integer types with different sign [-Wpointer-sign]
  return rb_str_new(b->top, b->cur - b->top);
                    ^~~~~~
/Users/ataka/.rbenv/versions/2.1.4/include/ruby-2.1.0/ruby/intern.h:704:29: note: passing argument to parameter here
VALUE rb_str_new(const char*, long);
                            ^
1 warning generated.
compiling mini_ssl.c
In file included from mini_ssl.c:3:
/Users/ataka/.rbenv/versions/2.1.4/include/ruby-2.1.0/ruby/backward/rubyio.h:2:2: warning: use "ruby/io.h" instead of "rubyio.h" [-W#warnings]
#warning use "ruby/io.h" instead of "rubyio.h"
 ^
mini_ssl.c:4:10: fatal error: 'openssl/bio.h' file not found
#include <openssl/bio.h>
         ^
1 warning and 1 error generated.
make: *** [mini_ssl.o] Error 1

make failed, exit code 2

Gem files will remain installed in /Users/ataka/github/test/vendor/bundle/ruby/2.1.0/gems/puma-2.13.4 for inspection.
Results logged to /Users/ataka/github/test/vendor/bundle/ruby/2.1.0/extensions/x86_64-darwin-15/2.1.0-static/puma-2.13.4/gem_make.out
```

## 調査ログ

`2.14.0` 以降は修正されているので、特に指定せずともインストール成功する。 `2.13.9` と `2.14.0` のdiff。

<script src="https://gist.github.com/gosyujin/86158483c4d6177e9f45.js"></script>
