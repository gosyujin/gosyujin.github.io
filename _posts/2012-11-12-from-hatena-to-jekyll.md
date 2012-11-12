---
layout: post
title: "はてなダイアリーのエントリをJekyllへ移行する"
description: ""
category: 
tags: [Ruby, Jekyll]
---
{% include JB/setup %}

## あらすじ

はてなダイアリーからJekylに移行したいんだけど、完全に移行し切るには過去の遺産(はてなダイアリーのエントリ)も移したいよ。

## はてなのエントリ取得

何はなくともエントリをエクスポートしてこない事には始まらない。管理画面から `データ管理 => インポート/エクスポート => はてなの日記データ形式` をDL。

## はてな => Jekyll

### どうやるか

はてなのエントリをJekyllで見るためには、恐らく2通りの方法がある。

1. はてなエントリをMarkdown記法に変換して、Jekylに突っ込む
1. はてなエントリから記事を作れるようにJekylにパーサを突っ込む

さて…。

### てっく煮ブログさんのJekyll

[俺の最強ブログ システムが火を噴くぜ - てっく煮ブログ](http://tech.nitoyon.com/ja/blog/2012/09/20/moved-completed/)

自分がどうすればいいのかなーと悩んでいる今、ものすごくタイムリーに移行なされており(タイムリーでした)、かつ自分のやりたい事(はてなエントリの移行など)を全てプラグインなどで実現されていたためすぐにGitHubを見に行きました。

[nitoyon/tech.nitoyon.com ・ GitHub](https://github.com/nitoyon/tech.nitoyon.com)

{% highlight console %}
$ git clone https://github.com/nitoyon/tech.nitoyon.com.git
{% endhighlight %}

ぐ…中身は結構複雑。

ソースを見る前にローカルで動くか見せてもらおうっと。

{% highlight console %}
$ vi Gemfile

gem 'jekyll'
gem 'hparser'
gem 'sass'
gem 'RedCloth'
gem 'rdiscount'
{% endhighlight %}
    
これで `bundle exec jekyll --server` で行けるかと思ったけど、なんか色々ないって言われる。

どうやらまだgemが最新版になっていないらしい(gemからJekyllを持ってくると、多分 JEKYLL_HOME/lib/jekyll/tags/post_url.rbがないとか言われる)ので、GitHubから最新版を持ってくる。

{% highlight console %}
$ git clone git://github.com/mojombo/jekyll.git # fa8400ab61cb8df176f9fb2ec52d85f93c7418a7より新しければ大丈夫そう
$ git clone git://github.com/hotchpotch/hparser.git # 4fbeefc8becc45ed18bf374bec9a2d862db473d5より以下同文
{% endhighlight %}

Jekyllとhparserはこれに置き換え。これで実行すると…おお、自分のローカルでてっく煮ブログが…！

なんとなく動かして、どうなっているか色々見てみる。

### コンバート

それでは、いよいよはてなのエントリ.xmlをhogehoge.htn * n個 のファイルにコンバートする。以下の作業は全て上記のてっく煮さんのブログをcloneした中を間借りして行なっている。己のリポジトリで行なってもできる。

- Gemfileに `nokogiri` を追加する

{% highlight console %}
$ vi Gemfile

gem 'nokogiri'  # コンバート用
{% endhighlight %}

- `_scripts/` 直下に `_posts` と `_caches` ディレクトリを作る
- `bundle exec ruby convert_hatena_to_jekyll_posts.rb HATENA_ID はてなのエントリ.xml` を実行！
- ……が、途中で止まる。どうやらUrl先のtitleを探しに行くとき、対象が404だった場合例外を吐くらしい

> 対象のコンテンツが 404 になっている場合には例外が出てスクリプトが停止します。
> その場合は _caches/url_title.json に手動でエントリを追加する、元のエントリを
> 修正する、などして回避してください。

との事なので、止まっては修正止まっては修正。最後まで行くと、hogehoge.htnの山が_posts下に築かれる。

※ これをskipがなくなるまでやる(スーパーpreの中の文頭にアスタリスクがあるとダメみたい(Gitのグラフなどダメだった))

……が。あれ？　はてなダイアリーの記事のタグが複数あってもhogehoge.htnにコンバートされると先頭の1個しか指定してくれていない？

### parse_dayメソッドをいじってみる…。

{% highlight ruby %}
    unless m = title.match(/^\*([^*]+)\*(\[.*\])(.*)/)
{% endhighlight %}

{% highlight ruby %}
     tags[0].gsub!("][", ",")
     tags[0].gsub!("[", "")
     tags[0].gsub!("]", "")
     tags = tags.join(",")
     tags.gsub!(",", ", ")

     content = {
       "layout" => "post", 
       "title" => name_ja,
       "description" => "",
       "catecory" => "",
       "tags" => tags + "]",
       "old_url" => "http://d.hatena.ne.jp/#{hatena_id}/#{old_url}",
     }.to_yaml
     
     content.gsub!("tags: ", "tags: [")
     
     content = content + "---\n" + convert_text(text, hatena_id)
{% endhighlight %}

これで、やりたいことができた……。

が、yamlの扱い方がよくわからん。hogehoge.htnファイルのtagsとして `tags: [aaa, bbb, ccc]` って出力したかったんだけど、配列の記述のまま `"[aaa, bbb, ccc]"` to_yamlすると hogehoge.htn内で `! ' [aaa, bbb, ccc] '` こう出力されてしまったので力技でうまくいくように。

まあ一回しか変換しないしいっか……。

これではてなダイアリーの全ての記事がhogehoge.htnとして `_posts` ディレクトリに生成された。

あとはこれを己のJekyllの `_posts` に放り込み、コンバートは完了。

## 起動/変換

最後にJekyllでhogehoge.htnファイルを静的ファイルに変換する。てっく煮さんのpluginがいくつかないと正常に変換されず、途中で止まるかも。

(要確認)とりあえず `_plugins` 下にこんだけあれば動いた。ここははてなダイアリーで使っている記法による？amazonを使ってなければamazon.rbはいらないかもしれない。

    converters
    ┣ hatena.rb
    ┣ ext
    ┃┗ post_to_liquid_raw.rb
    ┣ filters
    ┃┣ json_filter.rb
    ┃┣ locale_filter.rb
    ┃┗ simplify_rss_description.rb
    ┗ tags
      ┣ amazon.rb
      ┣ post_link.rb
      ┣ tweet.rb
      ┣ twitter.rb
      ┗ youtube.rb

プロジェクトのGemfileでは `Jekyll` と `hparser` をGutHubから最新のものを持ってくればそれで良いかな。(そのうちgemでも取れるようになると思うが)あと `albino` じゃなくて `pygments.rb` を使うようにする。

## 自分用TODO

- おかしい
  - 2009-10-19-1255949562.htn
  - 2011-05-01-1304204171.htn
  - 2011-10-08-1318068887.htn
  - 2011-11-27-1322329546.htn
  - 2011-11-28-1322482230.htn
  - 2011-12-16-1324086694.htn
