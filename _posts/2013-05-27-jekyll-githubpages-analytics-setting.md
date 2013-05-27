---
layout: post
title: "Jekyll@GitHub Pagesの運用形態を変えたのでAnalyticsの設定が効かなくなっていた"
description: ""
category: 
tags: [Jekyll, Ruby]
---
{% include JB/setup %}

## あらすじ

Jekyllで指定していたGoogle Analyticsの設定が効かなくなっていた。

他のGitHub Pages@Jekyllでは正しくGoogle Analyticsが動いているのに…。

## 結論

- 前回 GitHub Pages の運用形態を変えていた ... [GitHub PagesでJekyllプラグインを使えるようにするには…](http://gosyujin.github.io/2013/05/21/jekyll-plugin-githubpages/)
  - 変更前: `master` ブランチにコンテンツを配備し、GitHubにデプロイしてもらう
  - 変更後: `source` ブランチを作成しコンテンツを移動。ローカルでビルドした静的ファイルを `master` ブランチpush
- それによる **オプション指定の凡ミス**

おぉ…。

## 参考サイト

- [WordPressよりjekyllで本格的ブログを作りたくなる、かもしれないまとめ ｜ ゆっくりと…](http://tokkono.cute.coocan.jp/blog/slow/index.php/programming/making-blog-with-jekyll/)
- [30分のチュートリアルでJekyllを理解する](http://melborne.github.io/2012/05/13/first-step-of-jekyll/)
- [Jekyll ｜ CSS Radar ｜ Little Books For Front End Developers](http://css.studiomohawk.com/jekyll/2011/06/11/jekyll/)
- [Liquid for Designers · Shopify/liquid Wiki · GitHub](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers)
- [plusjade/jekyll-bootstrap · GitHub](https://github.com/plusjade/jekyll-bootstrap)

## ハマり

### 前提: GitHub Pagesの運用形態

指定のブランチに以下のようなファイル群を置いておく事で、GitHub Pagesができる。
 
1. Jekyllのコンテンツ
  - Jekyllに必要なファイルをpushしておけば、GitHubがよろしくデプロイしておいてくれる
1. 静的ファイル
  - そのまま表示される

Jekyllのコンテンツをpushして、後はおまかせするだけの運用は便利だけど、 **自作プラグインが動かない** という問題がある。

プラグインを動作させるためには、以下のように、あらかじめローカルでビルドした静的ファイルをpushしなければならない。

- `master` 以外の別ブランチ(仮に `source` ブランチ)を作成し、そこでJekyllのコンテンツを管理する
- ローカルの `source` ブランチで編集を終えたら、 `jekyll build` 
- 生成された成果物を `master` ブランチにpushする
  - ローカルでbuildしているので、プラグインが動作した状態で静的ファイルが出来ている
  - こんな感じの手法をとっているのがOctopress

この情報をもとに、Rakefileにdeployコマンドを作った。

https://github.com/gosyujin/gosyujin.github.com/blob/source/Rakefile

{% highlight ruby %}
# Usage: rake deploy
desc "Begin a push static file to GitHub"
task :deploy do
  sh "jekyll build"
  puts "! Push to source branch of GitHub"
  sh "git push origin source:source"
(略)
{% endhighlight %}

### analyticsの設定はどう読み込まれているのか

`_includes/JB/analytics` を見ると、analyticsを読み込むには以下の条件を満たす必要がある。

{% highlight ruby %}
{{"{% if site.safe and site.JB.analytics.provider and page.JB.analytics != false "}}%}

{{"{% case site.JB.analytics.provider "}}%}
{{"{% when "google" "}}%}
  {{"{% include JB/analytics-providers/google "}}%}
(略)
{% endhighlight %}

大事なのは、 **site.safe がtrue** である事。

このsafeオプションがtrueになっている条件を見落としてた。trueじゃないとanalytics読み込みはなされない。

しかし…。

※ safeはデフォルトではfalse

{% highlight console %}
$ bundle exec jekyll --help
    jekyll
(略)
    --safe 
        Safe mode (defaults to false)
{% endhighlight %}

※ https://help.github.com/articles/pages-don-t-build-unable-to-run-jekyll 本家のhelpでも `--safe` オプションよろしく！とのこと。

GitHubがJekyllのコンテンツをデプロイする際は、必ず `--safe` がつけられる。(そのため、自作プラグインが動かなくなる)

しかし、safeがfalseじゃないと自作のプラグインを動かせないので、 `_includes/JB/analytics` から `if site.safe` の条件を削除する事で対応。

ローカルで埋め込んだ後で、pushすればいい。

---

以下、どこが原因かわからなかったので、Jekyll Bootstrapのデフォルトファイルを読んでいった結果。

## 蛇足

### ディレクトリ構成

Jekyll Bootstrapを落としてくるとファイル構成はこう。

- 404.html
- README.md
- Rakefile
- _config.yml
- _includes/
- _layouts/
- _plugins/
- _posts/
- _site/
- archive.html
- assets/
- atom.xml
- categories.html
- changelog.md
- index.md
- pages.html
- rss.xml
- sitemap.txt
- tags.html

その中の `_layouts` ディレクトリの中にテンプレート的なファイルがある。

- _layouts/
  - default.html
  - page.html
  - post.html

htmlを見てみると…。

{% highlight ruby %}
$ cat _layouts/default.html
---
theme :
  name : twitter
---
{{"{% include JB/setup "}}%}
{{"{% include themes/twitter/default.html "}}%}
{% endhighlight %}

{% highlight ruby %}
$ cat _layouts/page.html 
---
layout: default
---
{{"{% include JB/setup "}}%}
{{"{% include themes/twitter/page.html "}}%}
{% endhighlight %}

{% highlight ruby %}
$ cat _layouts/post.html 
---
layout: default
---
{{"{% include JB/setup "}}%}
{{"{% include themes/twitter/post.html "}}%}
{% endhighlight %}

こんな感じ。はじめのハイフンで囲まれたエリアはyaml front matter？ http://jekyllrb.com/docs/frontmatter/

続いて、`JB/setup` と `themes/twitter/default.html` `page.html` `post.html` をインクルードしている。

`layout: default` と書かれている page.html と post.html は default.html を親にしている事がわかる。

### include JB/setup

_layout/default.html 一つ目の include である `JB/setup` を見てみる。 include なだけあって、 `_includes` ディレクトリにある。

{% highlight ruby %}
{{"{% capture jbcache "}}%}
  <!--
  - Dynamically set liquid variables for working with URLs/paths
  -->
  {{"{% if site.JB.setup.provider == "custom" "}}%}
    {{"{% include custom/setup "}}%}
  {{"{% else "}}%}
    {{"{% if site.safe and site.JB.BASE_PATH and site.JB.BASE_PATH != '' "}}%}
      {{"{% assign BASE_PATH = site.JB.BASE_PATH "}}%}
      {{"{% assign HOME_PATH = site.JB.BASE_PATH "}}%}
    {{"{% else "}}%}
      {{"{% assign BASE_PATH = nil "}}%}
      {{"{% assign HOME_PATH = "/" "}}%}
    {{"{% endif "}}%}

    {{"{% if site.JB.ASSET_PATH "}}%}
      {{"{% assign ASSET_PATH = site.JB.ASSET_PATH "}}%}
    {{"{% else "}}%}
      {{"{% capture ASSET_PATH "}}%}{{ BASE_PATH }}/assets/themes/{{ page.theme.name }}{{"{% endcapture "}}%}
    {{"{% endif "}}%}
  {{"{% endif "}}%}
{{"{% endcapture "}}%}{{"{% assign jbcache = nil "}}%}
{% endhighlight %}

site.JB.hogehogeの設定を確認して、パス設定などしているよう。

この `site.JB.hogehoge` っていうのは `_config.yml` に定義しているパラメータだよね。こんな感じで定義されている。

{% highlight ruby %}
JB :
  version : 0.3.0
  BASE_PATH : false
  ASSET_PATH : false
  archive_path: /archive.html
  categories_path : /categories.html
  tags_path : /tags.html
  atom_path : /atom.xml
  rss_path : /rss.xml
  (略)
{% endhighlight %}

どんな値になっているのか確認のため、 `JB/setup` の先頭に以下のような出力を足してみる。

{% highlight console %}
safe {{"{{site.safe"}}}} <br>
site.JB {{"{{site.JB"}}}} <br>
provider {{"{{site.JB.setup.provider"}}}} <br>
base {{"{{site.JB.BASE_PATH"}}}} <br>
asset {{"{{site.JB.ASSET_PATH"}}}} <br>
page name {{"{{ page.theme.name "}}}}
{{"{% capture jbcache "}}%}
略
{% endhighlight %}

で、実行結果。

{% highlight console %}
safe false 
site.JB {"version"=>"0.3.0", "BASE_PATH"=>false, "ASSET_PATH"=>false, "archive_path"=>"/archive.html", "categories_path"=>"/categories.html", "tags_path"=>"/tags.html", "atom_path"=>"/atom.xml", "rss_path"=>"/rss.xml", "comments"=>{"provider"=>"disqus", "disqus"=>{"short_name"=>"jekyllbootstrap"}, "livefyre"=>{"site_id"=>123}, "intensedebate"=>{"account"=>"123abc"}, "facebook"=>{"appid"=>123, "num_posts"=>5, "width"=>580, "colorscheme"=>"light"}}, "analytics"=>{"provider"=>"google", "google"=>{"tracking_id"=>"UA-123-12"}, "getclicky"=>{"site_id"=>nil}, "mixpanel"=>{"token"=>"_MIXPANEL_TOKEN_"}}, "sharing"=>{"provider"=>false}} 
provider 
base false 
asset false 
page name twitter
{% endhighlight %}

なるほど。実行結果的にはifの最後を通っているようなので、 ASSET_PATH の設定をしている事になる。

`ASSET_PATH = /assets/themes/twitter` となった。

### include themes/twitter/default.html 

_layouts/default.html の二つ目の include。一部を除き、htmlがつらつらと…。

{% highlight html %}
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>{{"{{ page.title "}}}}</title>
    {{"{% if page.description "}}%}<meta name="description" content="{{"{{ page.description "}}}}">{{"{% endif "}}%}
    <meta name="author" content="{{ site.author.name }}">

    <!-- Enable responsive viewport -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
(略)
    <div class="container-narrow">

      <div class="content">
        {{"{{ content "}}}}
      </div>
      <hr>
{% endhighlight %}

動的に表示させたい部分はliquidで埋め込んでいる。`{{"{{ "}}}}` とか `{{"{% "}}%}` で始まる部分がそう。

で、 `content` 部分に子？の内容が埋め込まれるのか。

### まとめ

rake post title=hoge として作った _posts/2013-xx-yy-hoge.md を表示するためには、こんな風に埋め込みしていっている？

![jekyll-page](http://gosyujin.github.io/images/2013-05-27/jekyll-page.png)
