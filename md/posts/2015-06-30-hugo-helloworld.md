---
layout: post
title: "Hugoを使ってみた"
description: ""
category:
tags: [Golang, Hugo]
old_url: http://d.hatena.ne.jp/kk_Ataka/20150630/1435664516
---

## あらすじ

自分がローカルで取りためているメモをいい感じで見るために使用する静的サイトジェネレータを選別してみた。

要望とか環境とか。

- PCの外には出さない
    - ローカルで作成して、出力して、ローカルで見る
- プレーンテキストでバージョン管理したい
- タグとかカテゴリである程度ジャンル分けしたい
- (できれば)Windowsでも(苦労せず)動かしたい

こんなことができそうな静的サイトジェネレータを探してみる…。

- Jekyll
- Middleman
- Pelican
- Sphinx
- Hugo
- あとはJavascript系からいくつか…

## 結果、Hugoにした

公式に書かれていることを信じて。

- Make the Web Fun Again
- Run Anywhere
- Fast & Powerful
- Flexible

Windowsでも結構使うので、個人的にはRun Anywhareがいいかなと思った。

Fast & Powerfulに関しては、他のサイトジェネレータから乗り換えた人が感じているようだけど、そんなに記事数増えない予定だからな～…と思っていた。

が、ビルド速度意外と大事だった。(後述)

## インストール手順

[公式のQuickstartガイド](http://gohugo.io/overview/quickstart/)より。

### Hugoインストール

割愛。バイナリファイルもあるので、それを持ってきてパス通す。`hugo`コマンドが実行できればOK。

```
>hugo version
Hugo Static Site Generator v0.13 BuildDate: 2015-05-12T10:43:12+09:00
```

### サイト新規作成

```html
>hugo new site mysite
```

こんな感じの階層でファイルができる。

```html
C:.
│  config.toml
│
├─archetypes
├─content
├─data
├─layouts
└─static
```

これがデフォルトの構造っぽい。

tomlファイルは初見だ。yamlのような感じか。

### Content作成

`content`ディレクトリはいわゆる記事の置き場かな。`hugo new`で`content`の下にファイルが生成される。

```html
>hugo new about.md
content\about.md created
```
## ビルド

ちょうどよいので、速度をはかるため今までのブログ記事を(最低限Hugoが変換できる程度になおして)ビルドをしてみた。

元の記事はJekyllで管理されている。

Migrate方法はまだ全部見ていないが公式にもある。[Migrate to Hugo from Jekyll](http://gohugo.io/tutorials/migrate-from-jekyll/)

```html
ファイルサイズ - ファイル名
2635 - 2012-10-10-jekyll-liquid-plugin.md
4898 - 2012-10-01-bundle-exec-bat.mdｄ
6387 - 2012-09-21-jekyll-pygments.md
3633 - 2012-09-20-jekyll.md
1702 - 2013-02-04-haskell-helloworld4.md
4814 - 2013-01-24-haskell-helloworld3.md
3625 - 2013-01-21-haskell-helloworld2.md
6795 - 2013-01-09-haskell-helloworld.md
3155 - 2012-12-31-kpt-2012.md
2837 - 2012-12-25-ruby-memo.md
7253 - 2012-12-12-git-svn-dcommit.md
6821 - 2012-11-12-from-hatena-to-jekyll.md
34406 - 2013-04-01-chef-helloworld.md
4028 - 2013-03-18-selenium-firefox-loaderror.md
8962 - 2013-03-07-selenium-ie-iphone-browser.md
3160 - 2013-03-03-evernote-oauth.md
12163 - 2013-02-25-ruby200-helloworld-pik-rvm.md
6369 - 2013-02-19-haskell-helloworld5.md
12823 - 2013-06-05-ios-over-the-air.md
10191 - 2013-05-27-jekyll-githubpages-analytics-setting.md
3392 - 2013-05-23-jekyll-liquid-plugin2.md
7679 - 2013-05-21-jekyll-plugin-githubpages.md
7100 - 2013-04-27-bpstudy68.md
3641 - 2013-04-11-jekyll-0120.md
2852 - 2013-08-20-rails3-log-not-colorize.md
14155 - 2013-08-09-redmine2.3-install-and-plugin.md
12300 - 2013-08-07-jekyll-maintenance-1.md
20019 - 2013-08-04-android-install-intent.md
7434 - 2013-07-18-ios-backup-restore.md
1398 - 2013-09-05-svn-proxy-error-by-git-svn.md
3189 - 2013-09-03-redmine-content-length-error.md
29634 - 2013-08-28-android-test-tools.md
4706 - 2013-08-26-utf8-space-c2a0.md
5269 - 2013-08-23-sphinx-install-python-proxy2.md
22168 - 2013-08-21-sphinx-install-python-proxy.md
7488 - 2013-12-24-ruby-qr.md
23097 - 2013-12-14-git-dotgit-objects.md
2665 - 2013-11-25-jekyll-plugin-reference.md
6594 - 2013-10-25-sphinx-recommend.md
7599 - 2013-10-02-sphinx-plugin.md
5653 - 2013-09-25-ios-uiwebview-cache.md
11685 - 2013-09-07-jekyll-maintenance-2.md
6009 - 2014-05-19-sphinx-recommend2.md
4348 - 2014-04-01-kawasakirb-010.md
6089 - 2014-03-13-jekyll-make-jekyllrb-com-jp.md
7733 - 2014-02-24-redmine-test.md
6515 - 2014-01-28-pull-request-to-jekyll.md
3018 - 2013-12-31-kpt-2013.md
3678 - 2014-07-13-kawasakirb-011-012-013.md
7870 - 2014-06-22-translated-jekyllrb.md
26526 - 2014-05-28-sphinx-latexpdfja-for-windows.md
2978 - 2014-07-26-jekyllrb-ja-meetupmd.md
2823 - 2014-08-28-kawasakirb-015.md
15897 - 2014-09-24-hubot-helloworld.md
2547 - 2014-10-27-sphinxconjp-2014.md
1176 - 2014-11-30-kawsakirb-018.md
2800 - 2014-12-23-kawasakirb-019.md
2285 - 2015-01-25-kpt-2014.md
1937 - 2015-02-28-excel-by-ruby.md
3545 - 2015-03-14-jekyll-changed-bindaddress.md
4185 - 2015-04-30-golang-helloworld.md
4110 - 2015-05-26-jenkins-environment-path.md
```

### jekyll build した場合

```html
$ time jekyll build
```

体感で8秒くらいかかってる。

real    |user    |sys
--------|--------|--------
0m7.955s|0m7.341s|0m0.527s
0m7.856s|0m7.409s|0m0.447s
0m7.818s|0m7.297s|0m0.529s
0m7.901s|0m7.402s|0m0.466s
0m7.594s|0m7.167s|0m0.440s

### hugoした場合

テーマは適当。

```html
$ hugo --theme=xxx
```

体感0.55秒。むっちゃはやい。

real    |user    |sys
--------|--------|--------
0m0.553s|0m0.912s|0m0.092s
0m0.613s|0m0.995s|0m0.111s
0m0.605s|0m0.985s|0m0.105s
0m0.518s|0m0.825s|0m0.091s
0m0.559s|0m0.887s|0m0.096s

このビルドスピードはかなり快適で、GitHub Pages自体Hugoに切り替えようと思ってしまうほどだった。

## まだよくわかってない

hugoのデフォルトコマンドの操作がちょっと気になるので、色々いじりたい。

が、どうするのが一番ベストなのかまだよくわかってない。例えば…、

1. `hugo new about`で`about.md`ファイルを作ってほしい
    - 拡張子指定するのめんどくさい
1. もっというと、2015/06/20に上記コマンドを実行したら`2015-06-20-about.md`ファイルを作ってほしい
    - 過去の資産との整合性をとりたい(ファイル命名規則)
1. `about`部分をtitleじゃなくslugに指定したい
    - タイトルは最終的に変えるから`""`とかでいい
    - 過去の資産との整合性をとりたい(パーマリンクに使用)
1. `archetypes/default.md`の使って新しいファイルを生成しているみたいなんだけど、勝手にFrontMatterをソートしたりするのやめてほしい
    - 過去の資産との整合性をとりたい

こういうことをしたいのだけど、どうするのが一番いいんだろう。(ドキュメントを全部読みきれていないので、もしかしたらコマンドのオプションとかconfig定義で解決できるものもあるかも)

- hugoソースに直接手を入れて実現すべき？
- hugoコマンドのラッパーコマンドを作るべき？(goで)
- hugoコマンドのラッパーコマンドを作るべき？(シェルスクリプトなどで)

いまはシェルスクリプトでやってる…。
