---
layout: post
title: "Jekyllがデフォルトでは外部から繋がらなくなってたよ"
description: ""
category: 
tags: [Jekyll]
---

## あらすじ

しばらく触っていなかったJekyllをアップデートしたときに他のPCからアクセスできなくてちょっとハマった。

[Ruby - Sinatraがデフォルトでは外部から繋がらなくなってたよ - Qiita](http://qiita.com/u1_fukui/items/b86b21f6ed39f4c10d5d) (タイトルはリスペクト)

## 解決策(暫定)

`_config.yml`に`host: 0.0.0.0`を定義するか、起動時に`--host 0.0.0.0`オプションを指定すればいいんだけどそれがもっともよいんだろうか。

常時あげっぱなしにはしないんだけど、どうしても一瞬別のPCで起動してそこに向けて(ローカルからだったり外からだったり)アタックしたい時があるので困っていた。

## 環境

```console
$ bundle show
Gems included by the bundle:
  * RedCloth (4.2.9)
  * blankslate (2.1.2.4)
  * bundler (1.6.1)
  * celluloid (0.15.2)
  * classifier (1.3.4)
  * coffee-script (2.3.0)
  * coffee-script-source (1.7.1)
  * colorator (0.1)
  * execjs (2.2.1)
  * fast-stemmer (1.0.2)
  * ffi (1.9.3)
  * hparser (0.4.0 dc35f05)
  * jekyll (2.1.1)
  * jekyll-coffeescript (1.0.0)
  * jekyll-gist (1.1.0)
  * jekyll-paginate (1.0.0)
  * jekyll-sass-conver.6.0)
  * rake (10.3.2)
  * rb-fsevent (0.9.4)
  * rb-inotify (0.9.5)
  * redcarpet (3.1.2)
  * ref (1.0.5)
  * safe_yaml (1.0.3)
  * sass (3.3.11)
  * therubyracer (0.12.1)
  * timers (1.1.0)
  * toml (0.1.1)
  * yajl-ruby (1.1.0)
```

`bundle update`は成功した。2.5.3まであがった。

## 困った

で、起動すると色々warningはあるものの一応成功はするのだが、BindAddressがいきなり変わってて外部からアクセスできなくなってた。

`jekyll serve`時の起動ログでアドレスが確認できる。

- Jekyll 2.4.0(ちょうど別環境で動くやつがあった)

```console
    Server address: http://127.0.0.1:4000/
```

- Jekyll 2.5.3

```console
    Server address: http://0.0.0.0:4000/
```

## 調査

とりあえず`jekyll-x.x.x/lib/jekyll/commands/serve.rb`を探る。

この辺でBindAddressにconfig['host']を入れてて、この初期(？)値が変わってる。

```ruby
def webrick_options(config)
  opts = {
    :BindAddress        => config['host'],
    :DirectoryIndex     => %w(index.html index.htm index.cgi index.rhtml index.xml),
    :DocumentRoot       => config['destination'],
    :DoNotReverseLookup => true,
    :MimeTypes          => mime_types,
    :Port               => config['port'],
    :StartCallback      => start_callback(config['detach'])
}
```

configってどこで初期化されてるんだっけ〜 -> `jekyll-x.x.x/lib/jekyll/configuration.rb`だった！

blameしていつ変更が入ったのか調べてみると、2014年の11月だった。

```console
commit a16dfef8403921aa08c95839a81b00134dbe12bd
Author: Alfred Xing <alfredxing@users.noreply.github.com>
Date:   Sun Nov 2 15:31:23 2014 -0800

    Use 127.0.0.1 as host instead of 0.0.0.0

diff --git a/lib/jekyll/configuration.rb b/lib/jekyll/configuration.rb
index 8a1d732..7f1148a 100644
--- a/lib/jekyll/configuration.rb
+++ b/lib/jekyll/configuration.rb
@@ -42,7    => '',
 
       # Backwards-compatibility options
```
