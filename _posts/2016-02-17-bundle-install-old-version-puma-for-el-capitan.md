---
layout: post
title: "El Capitan上に古いpumaをインストールすると失敗する"
description: ""
category: 
tags: [Ruby, Mac]
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

```sh
$ git log -p v2.13.4..v2.14.0 
commit 1cd87a600f51783f2908ea4085c6c596963013f2
Author: Evan Phoenix <evan@phx.io>
Date:   Fri Sep 18 09:45:35 2015 -0700

    Bump to 2.14.0

diff --git a/History.txt b/History.txt
index 60a2b93..d610532 100644
--- a/History.txt
+++ b/History.txt
@@ -1,3 +1,11 @@
+=== 2.14.0 / 2015-09-18
+
+* 1 minor feature:
+  * Make building with SSL support optional
+
+* 1 bug fix:
+  * Use Rack::Builder if available. Fixes #735
+
 === 2.13.4 / 2015-08-16
 
 * 1 bug fix:
diff --git a/lib/puma/const.rb b/lib/puma/const.rb
index bb3cc73..899912b 100644
--- a/lib/puma/const.rb
+++ b/lib/puma/const.rb
@@ -99,8 +99,8 @@ module Puma
   # too taxing on performance.
   module Const
 
-    PUMA_VERSION = VERSION = "2.13.4".freeze
-    CODE_NAME = "A Midsummer Code's Dream".freeze
+    PUMA_VERSION = VERSION = "2.14.0".freeze
+    CODE_NAME = "Fuchsia Friday".freeze
 
     FAST_TRACK_KA_TIMEOUT = 0.2
 

commit 302954190cb79b5dc58e82eedc8771bb506a21f8
Author: Evan Phoenix <evan@phx.io>
Date:   Fri Sep 18 09:43:51 2015 -0700

    Make building with SSL support optional

diff --git a/ext/puma_http11/extconf.rb b/ext/puma_http11/extconf.rb
index a2d7abd..752e06d 100644
--- a/ext/puma_http11/extconf.rb
+++ b/ext/puma_http11/extconf.rb
@@ -2,8 +2,12 @@ require 'mkmf'
 
 dir_config("puma_http11")
 
-if %w'crypto libeay32'.find {|crypto| have_library(crypto, 'BIO_read')} and
-    %w'ssl ssleay32'.find {|ssl| have_library(ssl, 'SSL_CTX_new')}
-  
-  create_makefile("puma/puma_http11")
+unless ENV["DISABLE_SSL"]
+  if %w'crypto libeay32'.find {|crypto| have_library(crypto, 'BIO_read')} and
+      %w'ssl ssleay32'.find {|ssl| have_library(ssl, 'SSL_CTX_new')}
+
+    have_header "openssl/bio.h"
+  end
 end
+
+create_makefile("puma/puma_http11")
diff --git a/ext/puma_http11/mini_ssl.c b/ext/puma_http11/mini_ssl.c
index 15a59cd..df019c8 100644
--- a/ext/puma_http11/mini_ssl.c
+++ b/ext/puma_http11/mini_ssl.c
@@ -1,6 +1,10 @@
 #define RSTRING_NOT_MODIFIED 1
+
 #include <ruby.h>
 #include <rubyio.h>
+
+#ifdef HAVE_OPENSSL_BIO_H
+
 #include <openssl/bio.h>
 #include <openssl/ssl.h>
 #include <openssl/dh.h>
@@ -347,6 +351,10 @@ VALUE engine_peercert(VALUE self) {
   return rb_cert_buf;
 }
 
+VALUE noop(VALUE self) {
+  return Qnil;
+}
+
 void Init_mini_ssl(VALUE puma) {
   VALUE mod, eng;
 
@@ -358,6 +366,8 @@ void Init_mini_ssl(VALUE puma) {
   mod = rb_define_module_under(puma, "MiniSSL");
   eng = rb_define_class_under(mod, "Engine", rb_cObject);
 
+  rb_define_singleton_method(mod, "check", noop, 0);
+
   eError = rb_define_class_under(mod, "SSLError", rb_eStandardError);
 
   rb_define_singleton_method(eng, "server", engine_init_server, 1);
@@ -371,3 +381,20 @@ void Init_mini_ssl(VALUE puma) {
 
   rb_define_method(eng, "peercert", engine_peercert, 0);
 }
+
+#else
+
+VALUE raise_error(VALUE self) {
+  rb_raise(rb_eStandardError, "SSL not available in this build");
+  return Qnil;
+}
+
+void Init_mini_ssl(VALUE puma) {
+  VALUE mod, eng;
+
+  mod = rb_define_module_under(puma, "MiniSSL");
+  rb_define_class_under(mod, "SSLError", rb_eStandardError);
+
+  rb_define_singleton_method(mod, "check", raise_error, 0);
+}
+#endif
diff --git a/lib/puma/binder.rb b/lib/puma/binder.rb
index b5029db..a484a5a 100644
--- a/lib/puma/binder.rb
+++ b/lib/puma/binder.rb
@@ -128,6 +128,8 @@ module Puma
 
           @listeners << [str, io]
         when "ssl"
+          MiniSSL.check
+
           params = Util.parse_query uri.query
           require 'puma/minissl'
 
@@ -253,6 +255,8 @@ module Puma
                          optimize_for_latency=true, backlog=1024)
       require 'puma/minissl'
 
+      MiniSSL.check
+
       host = host[1..-2] if host[0..0] == '['
       s = TCPServer.new(host, port)
       if optimize_for_latency
@@ -272,6 +276,8 @@ module Puma
 
     def inherited_ssl_listener(fd, ctx)
       require 'puma/minissl'
+      MiniSSL.check
+
       s = TCPServer.for_fd(fd)
       ssl = MiniSSL::Server.new(s, ctx)
 
diff --git a/lib/puma/minissl.rb b/lib/puma/minissl.rb
index 9779f29..03bee97 100644
--- a/lib/puma/minissl.rb
+++ b/lib/puma/minissl.rb
@@ -102,6 +102,8 @@ module Puma
       class SSLError < StandardError
         # Define this for jruby even though it isn't used.
       end
+
+      def self.check; end
     end
 
     class Context

commit cddcbe15ee554d6b78cce0261255b3b41f50ff09
Author: Evan Phoenix <evan@phx.io>
Date:   Wed Sep 9 09:10:33 2015 -0700

    Use Rack::Builder if available. Fixes #735

diff --git a/lib/puma/configuration.rb b/lib/puma/configuration.rb
index 3547c54..80d42f0 100644
--- a/lib/puma/configuration.rb
+++ b/lib/puma/configuration.rb
@@ -123,10 +123,24 @@ module Puma
       File.basename(Dir.getwd)
     end
 
+    # Load and use the normal Rack builder if we can, otherwise
+    # fallback to our minimal version.
+    def rack_builder
+      begin
+        require 'rack'
+        require 'rack/builder'
+      rescue LoadError
+        # ok, use builtin version
+        return Puma::Rack::Builder
+      else
+        return ::Rack::Builder
+      end
+    end
+
     def load_rackup
       raise "Missing rackup file '#{rackup}'" unless File.exist?(rackup)
 
-      rack_app, rack_options = Puma::Rack::Builder.parse_file(rackup)
+      rack_app, rack_options = rack_builder.parse_file(rackup)
       @options.merge!(rack_options)
 
       config_ru_binds = []
```
