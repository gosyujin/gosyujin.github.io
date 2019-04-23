---
layout: post
title: "rbenvを最新にして新しいバージョンのRubyをインストールできるようにする"
description: ""
category: 
tags: [Ruby]
old_url: http://d.hatena.ne.jp/kk_Ataka/20170330/1490831210
---

## あらすじ

- git cloneでインストールしたrbenvを最新にして新しいRubyをインストールする

ちょくちょく忘れるので

## 手順

[Basic GitHub Checkout](https://github.com/rbenv/rbenv#basic-github-checkout) に沿ってインストールすると、カレントディレクトリ直下に `~/.rbenv` と `~/.rbenv/plugins/ruby-build` があるはず。ここを最新にする。

```
$ cd ~/.rbenv
$ git pull
$ cd ~/.rbenv/plugins/ruby-build
$ git pull
```

`$ rbenv install -l` を実行してインストールできるRubyのバージョンを確認みる。

好きなバージョンをインストールする。
