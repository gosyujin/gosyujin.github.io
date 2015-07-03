---
layout: post
title: "記事の目次を出力するJekyllプラグインの改良"
description: ""
category: 
tags: [Jekyll, Liquid, Ruby]
---

## 前回までのあらすじ

[Jekyll(Liquid)で記事の目次を出力するプラグインを作ってみた](http://gosyujin.github.io/2012/10/10/jekyll-liquid-plugin/)

これの続き。昔の話すぎて、忘れないようにメモ。

### 前回の疑問

> …あれ？　別の環境でやったら hタグに section , section-1 , section-2 … って連番が振られてる！？　なんで！

これは原因がわかった。 使っているMarkdownパーサが違うだけだった。

- `rdiscount` … idなし
- `kramdown` … idにsection-xが振られる

## 今回やったこと

- kramdownで動くようにkramdownいじったりtree_list.rbいじったり
- プラスバグ修正

> 目次から記事へのリンク
>
> (略) めんどいので自動で振ってほしい

### kramdownのidの振り方

kramdownがhタグにidを振っている方法を調べてみると、

- 半角文字はそれが `そのままid` になる
- スペースは `ハイフン` になる
- 全角文字は `なくなる`
- 全部全角文字だった場合 `section` と振られる
- 2度目以降のsectionは順に `section-x` と振られる

こんな感じになっているっぽい。以下は一例。

見出しの内容 |hタグのid
-------------|---------
ほげいち     |\<h2 id="section">ほげ
ほげに     |\<h2 id="section-2">ほげに
ほげさん     |\<h2 id="section-3">ほげさん
hoge     |\<h2 id="hoge">hoge
piyoとは     |\<h2 id="piyo">piyoとは
ほげよん     |\<h2 id="section-4">ほげよん

#### ソース

実際にソースを見てみよう。 `kramdown-0.14.0\lib\kramdown\converter\base.rb` に書いてあった。<del>めんどくさいので</del> 今回は全ての見出しがsectionとなってほしいので、以下の行をコメントアウトした。

{% highlight ruby %}
# Generate an unique alpha-numeric ID from the the string +str+ for use as a header ID.
#
# Uses the option +auto_id_prefix+: the value of this option is prepended to every generated
# ID.
def generate_id(str)
  gen_id = str.gsub(/^[^a-zA-Z]+/, '')         # コメントアウト
  gen_id.tr!('^a-zA-Z0-9 -', '')               # コメントアウト
  gen_id.tr!(' ', '-')                         # コメントアウト
  gen_id.downcase!                             # コメントアウト
  gen_id = 'section' if gen_id.length == 0     # if 以降をコメントアウト
  @used_ids ||= {}
  if @used_ids.has_key?(gen_id)
    gen_id += '-' << (@used_ids[gen_id] += 1).to_s
  else
    @used_ids[gen_id] = 0
  end
  @options[:auto_id_prefix] + gen_id
end
{% endhighlight %}

これで半角だろうが全部section-xと振られるようになった。

…が、よく考えたら自分のプラグインでこれと同じ処理をしたら良かったんじゃ…。

### tree_list.rbのバグ修正

目次に貼ったリンクが正しい見出しに飛んでいるか確認してたら、一個バグ見つけた。

- 引用部分の見出しにもidが振られるが、tree_listでは文頭にある見出ししか集めてなかった
  - でも、正直引用部分の見出しは目次にはいらない…
    - 集めるだけ集めて捨てるか… 
