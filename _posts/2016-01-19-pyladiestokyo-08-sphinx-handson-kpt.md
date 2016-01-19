---
layout: post
title: "PyLadiesTokyo #8でSphinxハンズオンのTAをしてきた #sphinxjp"
description: ""
category: 
tags: [Sphinx, イベント]
---

## あらすじ

さる1/16に開催されたPyLadies TokyoにてSphinxのハンズオンが開催されたのでTAしてきました。

- [PyLadies Tokyo Meetup #8 - connpass](http://pyladies-tokyo.connpass.com/event/24076/)

<blockquote class="twitter-tweet" lang="ja"><p lang="en" dir="ltr">Sphinx hands-on in PyLadies Tokyo Meetup#8 !! <a href="https://twitter.com/hashtag/sphinxjp?src=hash">#sphinxjp</a> <a href="https://twitter.com/hashtag/PyLadiesTokyo?src=hash">#PyLadiesTokyo</a> <a href="https://t.co/hfwwMZb6hA">pic.twitter.com/hfwwMZb6hA</a></p>&mdash; sphinx-users.jp (@sphinxjp) <a href="https://twitter.com/sphinxjp/status/688265828190404608">2016, 1月 16</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## 振り返りKPT

### Keep

- [PyLadies Tokyo – Official Site](http://tokyo.pyladies.com/) は、現在別のCMSで構築されているがこれを機会にSphinxに乗り換える案が出ているようです！ナイスですね

### Problem

- 特に大きな問題もなく、もしもの時のために小さい電源タップを持参すると助かる時があるかも？

### Try

- ハンズオン質問あるあるみたいなものがまとめられるといいかも
    - ハンズオン資料( [sphinxjp / handson — Bitbucket](https://bitbucket.org/sphinxjp/handson) )とかSphinx-Users.jpのサイトを見てくと書いてあったりするけど

## ハンズオンあるある

### エディタ編

- 半角スペース、全角スペース、タブを可視化できるエディタだとエラーに気づきやすい…かも！？
    - 不意に混同するとハマっちゃう

### アウトプット編(html)

- テーマ、適用されてない？
    - (1.3以降の)デフォルトテーマである `alabaster` はそういう見た目なのだ
    - ブラウザの横幅を変えるとメニューバーが目に見えて変化するのでわかりやすい
- `default` があるのになんでデフォルトがこれじゃないの？(定番になりつつある質問)
    - Sphinx 1.3からデフォルトテーマは `alabaster` になった
    - あわせてデフォルトテーマ `default` は `classic` に名称変更されたが、互換性維持のために残っている
    - Sphinx 1.3でテーマを `default` に設定して `make html` すると `alabaster` 使いなよと警告が出る
    - [Sphinxの更新履歴 — Sphinx 1.3.2 ドキュメント](http://docs.sphinx-users.jp/changes.html)によると1.3b3でそうなった様子

```
$ make html
(略)
WARNING: 'default' html theme has been renamed to 'classic'. Please change your html_theme setting either to the new 'alabaster' default theme, or to 'classic' to keep using the old default.
(略)
```
