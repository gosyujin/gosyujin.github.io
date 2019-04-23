---
layout: post
title: "Subversionのproxy設定でいつもハマるやつ"
description: ""
category: 
tags: [Git, Subversion]
old_url: http://d.hatena.ne.jp/kk_Ataka/20130905/1378311577
---

## あらすじ

`git svn` しようとしたらエラー。

```console
$ git svn rebase
Malformed file: /c/Users/xxx/.subversion/servers:68: Option expected at
/usr/lib/perl5/site_perl/Git/SVN/Ra.pm line 81
```

## 環境

- Windows

svn バージョン等は失念。まあ、多分バージョンはあまり関係ないと思われる？

## 結論

`git-svn` の問題ではなく proxy 環境下 においての svn 設定ミスだった。

## 原因

`.subversion/server` の該当部分を見に行くとこうなっている。

```console
[global]
# http-proxy-exceptions = *.exception.com, www.internal-site.org
 http-proxy-host = proxy.xxx.jp
 http-proxy-port = 8080
```

proxy 設定を追加するためにコメントアウトを消したが。

- コメントアウト `#` を **一文字** 消しただけではダメ(上記の状態)
- **スペース** も消さなければならない

ただしくはこう。

```console
[global]
# http-proxy-exceptions = *.exception.com, www.internal-site.org
http-proxy-host = proxy.xxx.jp
http-proxy-port = 8080
```

これ、毎回設定する時にひっかかってるような気がする。
