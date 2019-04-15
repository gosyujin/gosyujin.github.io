---
layout: post
title: "Jekyllプロジェクトへpull requestを行う手順(したとは言っていない)"
description: ""
category: 
tags: [Jekyll, GitHub, Ruby]
---

## あらすじ

1. Jekyll に一点気になるところがあったのでなおしかたを調べた
1. せっかくなのでプルリクエストしてみたい！
1. …が、知らないこと多すぎて頓挫
1. とりあえず、今わかったところまでまとめた ← 今ここ

## なおした内容

Jekyll でかき集められた `tags` (タグのリスト) がバラバラのため、 tags.html ページから探すのがつらいのでソートをしたい。

### 修正内容

Jekyll のソースを追っていった結果、 `jekyll/lib/jekyll/site.rb` 内の一行をいじるだけでいけた。

```ruby
    def post_attr_hash(post_attr)
      # Build a hash map based on the specified post attribute ( post attr =>
      # array of posts ) then sort each array in reverse order.
      hash = Hash.new { |hsh, key| hsh[key] = Array.new }
      self.posts.each { |p| p.send(post_attr.to_sym).each { |t| hash[t] << p } }
      hash.values.map { |sortme| sortme.sort! { |a, b| b <=> a } }
-     hash
+     hash.sort
    end
```

hash の key でソートしてやる。

### 使用後のイメージ

[Tags - kk_Atakaの日記＠GitHub Pages](http://gosyujin.github.io/tags.html)

で。この内容を投げたいのだが、手順がまったくわからないので色々調査……。

## プルリクへの道

### 既に実装済みじゃないか調査

- とりあえず、既存機能(設定ファイルの操作など)では、タグのソートはできない…はず。やり方があったら教えて下さい
- 一応、 「 Liquid の領域」で頑張ればできる **かも** という情報は見つけた
- しかし、そもそもこの「タグをソートする」という機能が、どの領域で受け持つのが妥当なのかわからない( Liquid？ Jekyll？)
  - ソースを読んでいった結果、「タグの value (記事自体)のソート」を Jekyll でやっていたので、 key もここでやればいいんじゃね？と思った

### 既にプロジェクトへ要望としてあがっていないか調査

- [mojombo/jekyll ・ GitHub](https://github.com/mojombo/jekyll)

まずは、本家の Issues と Pull Requests を見てすでにあがってないか確認してみる。

`sort` とか `tag` とかで検索してみたが、特に類似しているチケットはない様子。(Issue 内検索とか、 プルリク内検索ってどうやるんだろう？)

### じゃあプルリクエストを送る

#### 一連の流れ

ここの進め方はプロジェクトによりけりだと思う。郷に入っては郷に従えで、 Jekyll では以下のページの手順に沿う。

- [Contributing](http://jekyllrb.com/docs/contributing/)

> - Fork the project.
> - Clone down your fork:
>
>>      git clone git://github.com/<username>/jekyll.git
>
> - Create a topic branch to contain your change:
>
>>      git checkout -b my_awesome_feature
>
> - `Hack away, add tests.` Not necessarily in that order.
> - `Make sure everything still passes by running rake.`
> - If necessary, `rebase your commits into logical chunks, without errors.`
> - Push the branch up:
>
>>      git push origin my_awesome_feature
>
> - Create a pull request against mojombo/jekyll and describe what your change does and the why you think it should be merged.

順を追って見てみる。

#### 最初の作業 fork とか

> - Fork the project.
> - Clone down your fork:
> - Create a topic branch to contain your change:

本家を fork して、ローカルに clone して、修正用のブランチを作る。

この辺はなんとなくわかる。

#### テストを作る

> - `Hack away, add tests.` Not necessarily in that order.

修正して **テストを追加** する。

`!! Contributions will not be accepted without tests` と言われているのでテストがないと門前払いっぽい。

ただ、テストって言われてもどう作ればいいのか…？

[Contributing](http://jekyllrb.com/docs/contributing/) に立ち戻ってみると、修正内容の種類によってどうすればよいか書かれていた。

1. 小さい修正か、既にある機能のパッチの場合
1. 新しい機能の場合
1. ドキュメンテーションの場合

今回は一つ目だな。

> If you’re creating a small fix or patch to an existing feature, just a simple test will do. Please stay in the confines of the current test suite and use Shoulda and RR.

Shoulda と RR を使ってテストを書けばいいの…？

※ ただし、両方とも聞いたことない

これに関しては一旦置いといて、続き。

#### Jekyll を壊してない事を確認したらプルリク

> - `Make sure everything still passes by running rake.`

rake を通せと。

確かに fork した Jekyll を rake すると、ガンガンテストが走りエラー 0 でフィニッシュした。

これを壊すなということか。

> - If necessary, `rebase your commits into logical chunks, without errors.`

エラーが出ないようにコミットを意味のあるかたまりに rebase せよ。

> - Push the branch up:

ブランチをプッシュせよ。

> - Create a pull request against mojombo/jekyll and describe what your change does and the why you think it should be merged.

最後に `mojombo/jekyll` にプルリクしてね。なぜ Jekyll は you の修正をマージすべきなのかを記載してね。

…結構果てしないな。

## Shoulda と RR

結局このテストツールの事がわからなかったので、テスト書けず。

調べてみよう……。

- [Test-driven Rails development with RSpec, RR, Shoulda, Factory Girl and Stubble｜casperfabricius.com](http://casperfabricius.com/site/2009/07/25/test-driven-rails-development-with-rspec-rr-shoulda-factory-girl-and-stubble/)

- [thoughtbot/shoulda ・ GitHub](https://github.com/thoughtbot/shoulda/tree/master)
- [RSpecよりShoulda、fixturesよりヘルパーとMocha - Unexplored Rails](http://d.hatena.ne.jp/irohiroki/20071024/shoulda)

- [rr/rr ・ GitHub](https://github.com/rr/rr)
- [eitoballの練習帳: rr README.rdoc（バージョン 0.10.10）私訳](http://eitoball.blogspot.jp/2010/03/rr-readmerdoc-01010.html)
