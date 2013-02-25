---
layout: post
title: "Ruby2.0.0 をpik経由でインストール&環境構築"
description: ""
category: 
tags: [Ruby, StartUp]
---
{% include JB/setup %}

## あらすじ

Ruby 2.0.0 がリリースされたので、インストールしつつ、新機能を使ってみる。

…と思ったけど、意外とてこずったし、rvmに関しては途中で止まったのでで、とりあえずインストールと準備だけ。

## 環境

- Windows XP
- Ruby 2.0.0
- pik

## インストール

まずはインストール。pikなので `pik install` で。

{% highlight console %}
$ pik install ruby 2.0.0
** Downloading:  http://rubyforge.org/frs/download.php/76807/ruby-2.0.0-p0-i386-mingw32.7z
   to:  C:\Documents and Settings\user\.pik\downloads\ruby-2.0.0-p0-i386-mingw32.7z

ruby-2.0.0-p0-i386-mingw32.7z: 100% |oooooooooo|   8.9MB/  8.9MB Time: 00:00:57

** Extracting:  C:\Documents and Settings\user\.pik\downloads\ruby-2.0.0-p0-i386-mingw32.7z
   to:  C:\rubies\Ruby-200-p0
done

** Adding:  200: ruby 2.0.0p0 (2013-02-24) [i386-mingw32]
 Located at:  C:\rubies\Ruby-200-p0\bin
{% endhighlight %}

あっさり。

{% highlight console %}
$ pik default
$ ruby -v
bundler is found: bundle exec ruby -v
ruby 1.9.3p0 (2011-10-30) [i386-mingw32]
{% endhighlight %}

今は、1.9.3。

{% highlight console %}
$ pik list
  167: jruby 1.6.7 (ruby-1.8.7-p357) (2012-02-22 3e82bc8) (Java HotSpot(TM) Client VM 1.6.0_04)...
  187: ruby 1.8.7 (2010-12-23 patchlevel 330) [i386-mswin32]
  187: ruby 1.8.7 (2011-06-30 patchlevel 352) [i386-mingw32]
  192: ruby 1.9.2p290 (2011-07-09) [i386-mingw32]
* 193: ruby 1.9.3p0 (2011-10-30) [i386-mingw32]
  200: ruby 2.0.0p0 (2013-02-24) [i386-mingw32]
$ pik use 200
$ pik list
  167: jruby 1.6.7 (ruby-1.8.7-p357) (2012-02-22 3e82bc8) (Java HotSpot(TM) Client VM 1.6.0_04)...
  187: ruby 1.8.7 (2010-12-23 patchlevel 330) [i386-mswin32]
  187: ruby 1.8.7 (2011-06-30 patchlevel 352) [i386-mingw32]
  192: ruby 1.9.2p290 (2011-07-09) [i386-mingw32]
  193: ruby 1.9.3p0 (2011-10-30) [i386-mingw32]
* 200: ruby 2.0.0p0 (2013-02-24) [i386-mingw32]
$ ruby -v
bundler is NOT found or Gemfile is NOT found: ruby -v
ruby 2.0.0p0 (2013-02-24) [i386-mingw32]
{% endhighlight %}

2.0.0に切り替わった！

gem確認。。。

{% highlight console %}
$ gem list
Failed to load C:/Documents and Settings/user/.gemrc because it doesn't contain valid YAML hash

*** LOCAL GEMS ***

bigdecimal (1.2.0)
io-console (0.4.2)
json (1.7.7)
minitest (4.3.2)
psych (2.0.0)
rake (0.9.6)
rdoc (4.0.0)
test-unit (2.0.0.0)
{% endhighlight %}

あれ？なんかエラー出る…。

色々動かしてみたら、どうも `空の.gemrc` があると、警告が出るようになった様子。出てても問題なさげ？

- Ruby 1.9.3
  - .gemrcなし: 何も出ない
  - 空.gemrc: 何も出ない
  - 記載あり.gemrc: 何も出ない
- Ruby 2.0.0
  - .gemrcなし: 何も出ない
  - 空.gemrc: `Failed to load ...`
  - 記載あり.gemrc: 何も出ない

という事で、今は特に使っていないので、いさぎよく.gemrcを削除。

### 環境構築

Bundlerだけでも入れておこうかな

{% highlight console %}
$ gem install bundler
Fetching: bundler-1.2.4.gem (100%)
Successfully installed bundler-1.2.4
Parsing documentation for bundler-1.2.4
Installing ri documentation for bundler-1.2.4
Done installing documentation for bundler (18 sec).
1 gem installed

$ ruby -v
bundler is found: bundle exec ruby -v
Bundler is not compatible with Ruby 2.0 or Rubygems 2.0.
Please upgrade to Bundler 1.3 or higher.
{% endhighlight %}

ガーン。Bundler 1.3以降じゃないと対応してないのかー。

あれ？GitHubには24 February 2013に1.3出てるって書かれてる。 - https://github.com/carlhuda/bundler

まだRubygemsに反映されていないのかな？なら直接入れてみよう。

一旦、旧Bundler削除。

{% highlight console %}
$ gem uninstall bundler
Remove executables:
        bundle

in addition to the gem? [Yn]  y
Removing bundle
Successfully uninstalled bundler-1.2.4
{% endhighlight %}

次に、上記のサイトからbundlerを落としてくる。

{% highlight console %}
$ git clone http://github.com/carlhuda/bundler.git
Cloning into 'bundler'...
remote: Counting objects: 28447, done.
remote: Compressing objects: 100% (9733/9733), done.
remote: Total 28447 (delta 19095), reused 27460 (delta 18213)Receiving objects:  99% (28163/28447), 2.47 MiB | 2.43 MiB/s
Receiving objects: 100% (28447/28447), 5.30 MiB | 2.43 MiB/s, done.
Resolving deltas: 100% (19095/19095), done.
Checking out files: 100% (214/214), done.
{% endhighlight %}

で、gemを作る。

{% highlight console %}
$ gem build bundler.gemspec
  Successfully built RubyGem
  Name: bundler
  Version: 1.3.0
  File: bundler-1.3.0.gem
{% endhighlight %}

`bundler-1.3.0.gem` ができるので、これをインストール。

{% highlight console %}
$ gem install --local bundler-1.3.0.gem
Successfully installed bundler-1.3.0
Done installing documentation for bundler (0 sec).
1 gem installed
$ bundle -v
Bundler version 1.3.0
{% endhighlight %}

入った。
プロジェクトだけbundle installしてみたけどうまく動いたので、とりあえずOKかな。