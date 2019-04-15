---
layout: post
title: "Jekyllで出力するタグをソートする 解決編"
description: ""
category:
tags: [Jekyll, Liquid]
---

## あらすじ

1年半前の記事[Jekyllプロジェクトへpull requestを行う手順(したとは言っていない) - kk_Atakaの日記](http://gosyujin.github.io/2014/01/28/pull-request-to-jekyll/#%E3%81%AA%E3%81%8A%E3%81%97%E3%81%9F%E5%86%85%E5%AE%B9)でこんな事をやりたがってた。

> Jekyll でかき集められた tags (タグのリスト) がバラバラのため、 tags.html ページから探すのがつらいのでソートをしたい。

で、こうした。

> Jekyll のソースを追っていった結果、 jekyll/lib/jekyll/site.rb 内の一行をいじるだけでいけた。

その後、悩んだりもした。

> - 一応、 「 Liquid の領域」で頑張ればできる かも という情報は見つけた
>
> - しかし、そもそもこの「タグをソートする」という機能が、どの領域で受け持つのが妥当なのかわからない( Liquid？ Jekyll？)
>
>     - ソースを読んでいった結果、「タグの value (記事自体)のソート」を Jekyll でやっていたので、 key もここでやればいいんじゃね？と思った

## 解法

Liquidでもできました。

```html
{% raw %}
{% assign sorted_tags = site.tags | sort %}
{% for tag in sorted_tags %}
  {% assign t = tag[0] %}
  <code><a href="/tags.html#{{ t }}">{{ t }} <sub>{{ site.tags[t].size }}</sub></a></code>
{% endfor %}
{% endraw %}
```

一年半越しに解決。
