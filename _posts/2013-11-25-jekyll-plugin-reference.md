---
layout: post
title: "Jekyllのプラグイン作成で複数ファイルにまたがったタグをどう扱えばいいのかわからない話"
description: ""
category: 
tags: [Jekyll]
---

## あらすじ

Jekyll ではてなダイアリーのような脚注をつけられるプラグインを作った。

- [gosyujin.github.com/_plugins/gosyujin.github.com/reference.rb](https://github.com/gosyujin/gosyujin.github.com/blob/1cac1dbbb34f271ce54ce3a85c69261af3336aec/_plugins/gosyujin.github.com/reference.rb)

文中に登場した `ref` タグの引数を集めて `ref_anchor` タグが打たれた箇所にリスト出力する、というもの。

こう書くと、

{% highlight console %}
- 超スタンダード {{ " {% ref といわれている " }} %}
- 誰の PC にも入っている {{ " {% ref といわれている " }} %}
- 誰でも簡単に使える {{ " {% ref といわれている " }} %}
- きめ細かいデザインが可能
- 画像やフローの挿入も簡単

(略)

{{ " {% ref_anchor " }} %}
{% endhighlight %}

こうなる。

![ref](http://gosyujin.github.io/static/images/2013-11-25/ref.png)

(略)

![refanc](http://gosyujin.github.io/static/images/2013-11-25/refanc.png)

一応、やりたいことはできたんだけど、以下のようなことができなくて力技でなんとかした。

## できる

*同じ .md ファイル内に* `ref` タグと `ref_anchor` タグを書くと問題なくいける。

上記あらすじの例がそう。

## できない

`ref` タグは .md ファイル内に。 `ref_anchor` タグは「記事の一番最後に一つあればいい」ということでテーマ内に書いて集約したい。

と思って、 *テーマ( _includes/themes/twitter/post.html )* に書いてみたが、これだと脚注が拾えなかった…。

- [_includes/themes/twitter/post.html](https://github.com/gosyujin/gosyujin.github.com/blob/cbfe075f348e20d17850074af4/_includes/themes/twitter/post.html)

デバッグしてみると、どうもレンダリングの順番で、 `_includes/themes/twitter/post.html(ref_anchor) -> _posts/xxx.md(ref)` になっているから拾えないっぽい？

## 対応

うまくできる方法もあるのかもしれないけど、とりあえずグローバル変数を使う方法で脚注を拾うことに成功した。

もう一つ、記事と脚注の対応をjson形式とかでどっかにファイルに吐き出して、それを読み込むという手も考えたんだけど、どっちがいいんだろう。

あんまりグローバル変数使いたくないんだけど、他に思いつかなかった。
