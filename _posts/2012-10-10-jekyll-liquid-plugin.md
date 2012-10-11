---
layout: post
title: "Jekyll(Liquid)で記事の目次を出力するプラグインを作ってみた"
description: ""
category: 
tags: [Jekyll, Liquid, Ruby]
---
{% include JB/setup %}

## あらすじ

Jekyllのプラグイン作成の練習。エントリから見出しを抽出して目次を出力してみたい。

## 参考サイト

- [最近作った Jekyll (Liquid) のプラグイン - @yuumi3のお仕事日記](http://d.hatena.ne.jp/yuum3/20120711/1341998687)

## ソース

- [gosyujin.github.com/_plugins/tree_list.rb at master · gosyujin/gosyujin.github.com · GitHub](https://github.com/gosyujin/gosyujin.github.com/blob/master/_plugins/tree_list.rb)

### まだできてない事

- 記事中に `h1 (#)` タグがあるとうまく生成されない
  - 記事タイトルが `h1 (#)` なので、 `h2 (##)` 以下の見出しを集めてくるようにしている
- 目次から記事へのリンク
  - Markdownでは `## <a name="section"> hoge` と記載すればnameを振ってくれるようだけど、めんどいので自動で振ってほしい
  - **むしろ今はaタグを入れているとレイアウトが崩れる**
    - …あれ？　別の環境でやったら `h`タグに `section` , `section-1` , `section-2` ... って連番が振られてる！？　なんで！

## 作り方

最小単位はこうなるみたい。(何もしないプラグイン)

{% highlight ruby %}
module Jekyll
  class SampleTag < Liquid::Tag
    def initialize(tag_name, xxx, tokens)
      super
    end

    def render(context)
    end
  end
end

Liquid::Template.register_tag('sample', Jekyll::SampleTag)
{% endhighlight %}

これでMarkdown中に `{{ "{% sample hogehoge fuga " }} %}` と書くと、initializeメソッドの `tag_name` にsample、 `xxx` にhogehoge fuga、 `tokens` に本文が渡される。

という事でタグにつけた引数や本文を使う場合はinitializeで確保しとく。

renderメソッドでreturnした文字列がそのままページに出力される。

※ 新しくタグを作ったときは、Jekyllを再起動しないと `Unknown tag` が出続ける。

## 例

- 己のJekyll下の `_plugins` に `tree_list.rb` を突っ込む
- html(postするMarkdownファイルでもいいし、テンプレートのhtmlでもいい)のどこかに `{{ "{% tree " }} %}` を埋め込む
- `$ jekyll --server` 実行後localhost:4000にアクセス

これで文中の見出しが目次としてかき集められる。ただし、GitHub Pagesを使っている場合はソースをそのままpushするだけではダメで、対策が必要っぽい。
