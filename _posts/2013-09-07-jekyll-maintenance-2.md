---
layout: post
title: "Jekyllバージョンアップの際に思いのほか手こずった話 てっく煮さん製プラグインの更新に追従したい編"
description: ""
category: 
tags: [Ruby, Git, Jekyll]
---
{% include JB/setup %}

## 前回までのあらすじ

- [Jekyllバージョンアップの際に思いのほか手こずった話 Jekyll Bootstrapの更新に追従したい編](http://gosyujin.github.io/2013/08/07/jekyll-maintenance-1/)

## 結論

fork していれば、だいたいなんとかなる。

## 環境

- Ruby 1.9.3
  - RedCloth (4.2.9)
  - bundler (1.3.5)
  - classifier (1.3.3)
  - colorator (0.1)
  - commander (4.1.4)
  - directory_watcher (1.4.1)
  - fast-stemmer (1.0.2)
  - highline (1.6.19)
  - hparser (0.4.0 dc35f05)
  - jekyll (1.0.0 9f94eaf)
  - kramdown (0.14.2)
  - liquid (2.5.1)
  - maruku (0.6.1)
  - posix-spawn (0.3.6)
  - pygments.rb (0.4.2)
  - rake (10.1.0)
  - rdiscount (2.1.6)
  - redcarpet (2.2.2)
  - safe_yaml (0.7.1)
  - syntax (1.0.0)
  - yajl-ruby (1.1.0)

## 参考サイト

- [Git で複数のリポジトリをまとめたり、逆に切り出したりする - Qiita [キータ]](http://qiita.com/uasi/items/77d41698630fef012f82)

## やりたい事: てっく煮プラグイン編

@nitoyon さんが公開しているリポジトリ( https://github.com/nitoyon/tech.nitoyon.com )内の `_plugins` を使わせていただきたい。

はじめはコピペで自分のリポジトリの `_plugins` 下に持ってきていた。

が、前述の通りコピペしただけなので更新に追従できず自爆。

どうしよう。プラグインだけ追従とかできるんだろうか。

### 方針

- `_plugins` 下に置いておいて、折りを見て更新したい
- コピペは避けたい
- 自分用に少し手を入れたり、使う予定のないプラグインは削除したい
  - 例えば、先走ってJekyllのバージョンあげて互換性がなくなっちゃった場合の緊急回避策として(後述)

以降、三つのリポジトリが出てくるので、便宜上こう呼ぶ。

- `本家`
  - てっく煮さんのリポジトリ
  - [nitoyon/tech.nitoyon.com ・ GitHub](https://github.com/nitoyon/tech.nitoyon.com)
- `forkした本家`
  - `本家` を fork したてっく煮リポジトリ(自分のアカウントにひもづいている)
  - [gosyujin/tech.nitoyon.com ・ GitHub](https://github.com/gosyujin/tech.nitoyon.com)
- `自分のJekyll`
  - この記事をコミットしてる己のリポジトリ
  - [gosyujin/gosyujin.github.com ・ GitHub](https://github.com/gosyujin/gosyujin.github.com)

### その1: 本家リポジトリをそのまま一部サブモジュール化(断念)

`本家` リポジトリを `自分のJekyll` リポジトリ内にサブモジュールとして clone してくる。

{% highlight console %}
$ cd gosyujin.github.com
$ git submodule add http://github.com/nitoyon/tech.nitoyon.com.git _plugins/tech.nitoyon.com
Cloning into '_plugins/tech.nitoyon.com'...
remote: Counting objects: 15343, done.
remote: Compressing objects: 100% (4228/4228), done.
remote: Total 15343 (delta 5610), reused 14585 (delta 4852)
Receiving objects: 100% (15343/15343), 10.39 MiB | 623 KiB/s, done.
Resolving deltas: 100% (5610/5610), done.
warning: LF will be replaced by CRLF in .gitmodules.
The file will have its original line endings in your working directory.
{% endhighlight %}

※ Windowsの場合、パスの区切りに円マークを使うとうまくいかない？

以下のようなエラーが出た。

{% highlight console %}
$ git --version
git version 1.8.1.msysgit.1
$ git submodule add http://github.com/nitoyon/tech.nitoyon.com.git _plugins\tech.nitoyon.com
fatal: Could not switch to '.git/modules/_plugins\': No such file or directory
Clone of 'http://github.com/nitoyon/tech.nitoyon.com.git' into submodule path '_plugins\tech.nitoyon.com' failed
{% endhighlight %}

サブモジュールとして引っ張ってくると、リポジトリの中身全部入りで取得されてしまう。

次に `_plugins` ディレクトリだけを切りだす。

{% highlight console %}
$ cd _plugins\tech.nitoyon.com\
$ ls -a
./                           _layouts/                    favicon.ico
../                          _plugins/                    images/
.git                         _posts/                      img/
.gitignore                   _scripts/                    index.cgi
.htaccess                    about.css                    ja/
Gruntfile.js*                apple-touch-icon-114x114.png javascripts/
README.markdown              apple-touch-icon-72x72.png   misc/
_caches/                     apple-touch-icon.png         package.json
_config.yml                  blog.cgi                     stylesheets/
_includes/                   en/                          techni.css
_lang/                       entry.cgi
$ git filter-branch --subdirectory-filter _plugins HEAD
Rewrite 942d387c8d9d2f43efe2301cae1abe5ac7e489de (61/61)
Ref 'refs/heads/master' was rewritten
$ ls
archives.rb* converters/  ext/         filters/     lang.rb*     tags/        tags.rb*
{% endhighlight %}

これで、更新されたら fetch すれば `自分のJekyll` にも更新が反映されるはず。

#### サブモジュールの更新…できない？

なんだけど、このサブモジュールに対する変更(とかファイル削除)ってどうやればいいんだ…？

ローカルでは好き放題できるし、コミット自体もできるけどそれを push する術と場所がない？

- [transitive.info - git submodule 使い方](http://transitive.info/article/git/command/submodule/)

> - サブモジュールに対しては編集できない

やっぱり fork 必須？

……ってことは、

- `本家`
  - fork するだけ
- `forkした本家`
  - ここで `本家` リポジトリへの更新追従とプラグインの変更などを行う
- `自分のJekyll`
  - `forkした本家` の `_plugins` 以下をサブモジュールとして適用

するのが良いのか？というかしないとダメ？

### その2: 本家リポジトリを一回forkしてそこから更新分を持ってくる(採用)

結局 Jekyl Bootstrap のケースと同じく fork するのが一番？

#### 本家

まずは `本家` を GitHub 上から fork 。

#### fork した本家

`forkした本家` をローカルに clone する。

{% highlight console %}
$ git clone http://github.com/gosyujin/tech.nitoyon.com.git
{% endhighlight %}

プラグインの変更などをする場合はここで行い、修正内容を push する。

また、 `本家` の更新にもガンガン追従していく。

#### 自分の Jekyll

その1 でやった「サブモジュールとして持ってきて、 `_plugins` だけ切り出す」を `forkした本家` と `自分のJekyll` 間で行う。

{% highlight console %}
$ cd gosyujin.github.com
$ git submodule add http://github.com/gosyujin/tech.nitoyon.com.git _plugins/tech.nitoyon.com
$ git filter-branch --subdirectory-filter _plugins HEAD
{% endhighlight %}

これで `自分のJekyll` 内にてっく煮プラグインが入った。

なおかつ、プラグインの修正などは `forkした本家` で自由にでき、 `本家` の更新への追従もここでできる。

という感じで運用できるだろうか。

---

## おまけ 先走ってJekyllのバージョンあげて互換性がなくなっちゃった場合の緊急回避策

例えばこんな場合。

Jekyll を 1.0.0 から 1.2.2 に一気に上げた場合( pygments.rb も)、以下のようなエラーが起こってしまった。

{% highlight ruby %}
gem 'jekyll', :git => 'http://github.com/mojombo/jekyll.git', :tag => 'v1.1.2'
gem 'pygments.rb', '=0.5.0'
{% endhighlight %}

{% highlight console %}
  Generating... C:/work/gosyujin.github.com/_plugins/tech.nitoyon.com/ext/post_to_liquid_raw.rb:56:in `to_liquid': wrong number of arguments (1 for 0) (ArgumentError)
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/lib/jekyll/post.rb:255:in `render'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/lib/jekyll/site.rb:213:in `block in render'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/lib/jekyll/site.rb:212:in `each'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/lib/jekyll/site.rb:212:in `render'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/lib/jekyll/site.rb:44:in `process'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/lib/jekyll/command.rb:18:in `process_site'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/lib/jekyll/commands/build.rb:23:in `build'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/lib/jekyll/commands/build.rb:7:in `process'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/bundler/gems/jekyll-0db5dcf83217/bin/jekyll:96:in `block (2 levels) in <top (required)>'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/gems/commander-4.1.4/lib/commander/command.rb:180:in `call'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/gems/commander-4.1.4/lib/commander/command.rb:180:in `call'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/gems/commander-4.1.4/lib/commander/command.rb:155:in `run'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/gems/commander-4.1.4/lib/commander/runner.rb:402:in `run_active_command'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/gems/commander-4.1.4/lib/commander/runner.rb:78:in `run!'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/gems/commander-4.1.4/lib/commander/delegates.rb:11:in `run!'
      from C:/work/gosyujin.github.com/vendor/bundle/ruby/1.9.1/gems/commander-4.1.4/lib/commander/import.rb:10:in `block in <top (required)>'
{% endhighlight %}

{% highlight ruby %}
    # add 'raw' attribute
    def to_liquid
      self.to_liquid_orig.deep_merge({
        "raw" => ToDrop.new(self)
      })
    end
{% endhighlight %}

うーむ `post_to_liquid_raw.rb` で呼んでる `to_liquid` の引数がおかしいと。

実装元のdiffをとってみる。

{% highlight console %}
$ cd C:\work\gosyujin.github.com\vendor\bundle\ruby\1.9.1\bundler\gems\jekyll-0db5dcf83217\lib\jekyll
$ git diff v1.1.0..v1.1.2 -- ./post.rb
diff --git a/lib/jekyll/post.rb b/lib/jekyll/post.rb
index 1b70e31..9ad2539 100644
--- a/lib/jekyll/post.rb
+++ b/lib/jekyll/post.rb
(略)
@@ -272,8 +275,8 @@ module Jekyll
     # Convert this post into a Hash for use in Liquid templates.
     #
     # Returns the representative Hash.
-    def to_liquid
-      further_data = Hash[ATTRIBUTES_FOR_LIQUID.map { |attribute|
+    def to_liquid(attrs = ATTRIBUTES_FOR_LIQUID)
+      further_data = Hash[attrs.map { |attribute|
{% endhighlight %}

すると v1.1.0 から v1.1.2 の間( v1.1.1 )で `to_liquid` に引数が加えられてる！

※ `ATTRIBUTES_FOR_LIQUID` はこんな定数が入っていた: `["title", "url", "date", "id", "categories", "next", "previous", "tags", "path", "content", "excerpt"]`

`post_to_liquid_raw.rb` の `to_liquid` にこの引数を足せばエラーが解消できるみたい。

…と、こういうちょいなおしをするためにも直接持ってこないで fork した方が自由がきいてよいかという話。
