---
layout: post
title: "Ruby 2.0.0 をpikとrvm経由でインストール&環境構築"
description: ""
category: 
tags: [Ruby, StartUp]
old_url: http://d.hatena.ne.jp/kk_Ataka/20130225/1361802565
---

## あらすじ

Ruby 2.0.0 がリリースされたので、インストールしつつ、新機能を使ってみる。

…と思ったけど、意外とてこずったので、とりあえずインストールと準備だけ。

後途中にGemの作り方めも。

## 環境1

- Windows XP
- Ruby 2.0.0
- pik

## インストール

まずはインストール。pikなので `pik install` で。

```console
$ pik install ruby 2.0.0
** Downloading:  http://rubyforge.org/frs/download.php/76807/ruby-2.0.0-p0-i386-mingw32.7z
   to:  C:\Documents and Settings\user\.pik\downloads\ruby-2.0.0-p0-i386-mingw32.7z

ruby-2.0.0-p0-i386-mingw32.7z: 100% |oooooooooo|   8.9MB/  8.9MB Time: 00:00:57

** Extracting:  C:\Documents and Settings\user\.pik\downloads\ruby-2.0.0-p0-i386-mingw32.7z
   to:  C:\rubies\Ruby-200-p0
done

** Adding:  200: ruby 2.0.0p0 (2013-02-24) [i386-mingw32]
 Located at:  C:\rubies\Ruby-200-p0\bin
```

あっさり。

```console
$ pik default
$ ruby -v
bundler is found: bundle exec ruby -v
ruby 1.9.3p0 (2011-10-30) [i386-mingw32]
```

今は、1.9.3。

```console
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
```

2.0.0に切り替わった！

gem確認。。。

```console
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
```

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

```console
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
```

ガーン。Bundler 1.3以降じゃないと対応してないのかー。

あれ？GitHubには24 February 2013に1.3出てるって書かれてる。

- [carlhuda/bundler · GitHub](https://github.com/carlhuda/bundler)

まだRubygemsに反映されていないのかな？なら直接入れてみよう。

一旦、旧Bundler削除。

```console
$ gem uninstall bundler
Remove executables:
        bundle

in addition to the gem? [Yn]  y
Removing bundle
Successfully uninstalled bundler-1.2.4
```

次に、上記のサイトからbundlerを落としてくる。

```console
$ git clone http://github.com/carlhuda/bundler.git
Cloning into 'bundler'...
remote: Counting objects: 28447, done.
remote: Compressing objects: 100% (9733/9733), done.
remote: Total 28447 (delta 19095), reused 27460 (delta 18213)Receiving objects:  99% (28163/28447), 2.47 MiB | 2.43 MiB/s
Receiving objects: 100% (28447/28447), 5.30 MiB | 2.43 MiB/s, done.
Resolving deltas: 100% (19095/19095), done.
Checking out files: 100% (214/214), done.
```

で、gemを作る。

```console
$ gem build bundler.gemspec
  Successfully built RubyGem
  Name: bundler
  Version: 1.3.0
  File: bundler-1.3.0.gem
```

`bundler-1.3.0.gem` ができるので、これをインストール。

```console
$ gem install --local bundler-1.3.0.gem
Successfully installed bundler-1.3.0
Done installing documentation for bundler (0 sec).
1 gem installed
$ bundle -v
Bundler version 1.3.0
```

入った。
1プロジェクトだけbundle installしてみたけどうまく動いたので、とりあえずOKかな。

次。

## 環境2

- CentOS 6.2
- Ruby 2.0.0
- rvm 1.11.6

## インストール

……する前に。そのままだと `rvm list known` を見てもruby 1.9.3までしかないので、rvmの更新を行う。

- [RVM がかなり古くなってたので、RVM のアップデートに挑戦 - KUROIGAMEN(黒い画面)](http://kuroigamen.com/51)

```console
$ rvm -v

rvm 1.11.6 () by Wayne E. Seguin <wayneeseguin@gmail.com>, Michal Papis <mpapis@gmail.com> [https://rvm.beginrescueend.com/]
```

```console
$ rvm get latest
Downloading RVM version 1.18.14
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   125  100   125    0     0    147      0 --:--:-- --:--:-- --:--:--   193
100 1490k  100 1490k    0     0   315k      0  0:00:04  0:00:04 --:--:--  493k

Upgrading the RVM installation in /home/kk_Ataka/.rvm/
    RVM PATH line found in /home/kk_Ataka/.bashrc.
    RVM sourcing line found in /home/kk_Ataka/.bashrc /home/kk_Ataka/.bash_profile /home/kk_Ataka/.zlogin.

Upgrade Notes:

  * For screen users, please do not forget to read https://rvm.io/workflow/screen/.
  * If your shell exits on entering a directory with freshly checked out sources
  * RVM comes with set of default gems including 'bundler', 'rake', 'rubygems-bundler' and 'rvm' gems,
    if you do not wish to get this gems install RVM with this flag: --without-gems="rvm rubygems-bundler"
    this option is remembered, it's enough to use it once.

  * If you wish to get more default(global) gems installed, install RVM with this flag: --with-gems="pry vagrant"
    this option is remembered, it's enough to use it once.

  * For first installed ruby RVM will: display rvm requirements, set it as default and use it.
    To avoid this behavior either use full path to rvm binary or prefix it with `command `.

  * Binary rubies are installed by default if available, you can read about it in help:
      rvm help install
      rvm help mount

  * The default umask for multi-user installation got extended to `umask u=rwx,g=rwx,o=rx`,
    comment it out to avoid automatic updates.


# RVM:  Shell scripts enabling management of multiple ruby environments.
# RTFM: https://rvm.io/
# HELP: http://webchat.freenode.net/?channels=rvm (#rvm on irc.freenode.net)
# Cheatsheet: http://cheat.errtheblog.com/s/rvm/
# Screencast: http://screencasts.org/episodes/how-to-use-rvm

# In case of any issues read output of 'rvm requirements' and/or 'rvm notes'

Upgrade of RVM in /home/kk_Ataka/.rvm/ is complete.

# kk_Ataka,
#
#   Thank you for using RVM!
#   I sincerely hope that RVM helps to make your life easier and
#   more enjoyable!!!
#
# ~Wayne

RVM reloaded!
```

一覧を確認すると……あった。

```console
$ rvm list known
# MRI Rubies
[ruby-]1.8.6[-p420]
[ruby-]1.8.7[-p371]
[ruby-]1.9.1[-p431]
[ruby-]1.9.2[-p320]
[ruby-]1.9.3-p125
[ruby-]1.9.3-p194
[ruby-]1.9.3-p286
[ruby-]1.9.3-p327
[ruby-]1.9.3-p362
[ruby-]1.9.3-p374
[ruby-]1.9.3-p385
[ruby-]1.9.3-[p392]
[ruby-]1.9.3-head
[ruby-]2.0.0-rc1
[ruby-]2.0.0-rc2
[ruby-]2.0.0[-p0]
ruby-head

# GoRuby
goruby
...
```

そしてインストール。でもここで止まる……。

```console
$ rvm install ruby-2.0.0
Searching for binary rubies, this might take some time.
No binary rubies available for: centos/6.2/x86_64/ruby-2.0.0-p0.
Continuing with compilation. Please read 'rvm mount' to get more information on binary rubies.
Fetching yaml-0.1.4.tar.gz to /home/kk_Ataka/.rvm/archives
######################################################################## 100.0%
Extracting yaml to /home/kk_Ataka/.rvm/src/yaml-0.1.4
Prepare yaml in /home/kk_Ataka/.rvm/src/yaml-0.1.4.
Configuring yaml in /home/kk_Ataka/.rvm/src/yaml-0.1.4.
Compiling yaml in /home/kk_Ataka/.rvm/src/yaml-0.1.4.
Installing yaml to /home/kk_Ataka/.rvm/usr
Installing Ruby from source to: /home/kk_Ataka/.rvm/rubies/ruby-2.0.0-p0, this may take a while depending on your cpu(s)...
ruby-2.0.0-p0 - #downloading ruby-2.0.0-p0, this may take a while depending on your connection...
######################################################################## 100.0%
ruby-2.0.0-p0 - #extracting ruby-2.0.0-p0 to /home/kk_Ataka/.rvm/src/ruby-2.0.0-p0
ruby-2.0.0-p0 - #extracted to /home/kk_Ataka/.rvm/src/ruby-2.0.0-p0
ruby-2.0.0-p0 - #configuring
ruby-2.0.0-p0 - #compiling
```

かなり時間がかかったので、どこかで処理が止まっているのかなと思い一回abortさせてしまったが、再度挑戦したらいけた。

```console
$ rvm install ruby-2.0.0
Searching for binary rubies, this might take some time.
No binary rubies available for: centos/6.2/x86_64/ruby-2.0.0-p0.
Continuing with compilation. Please read 'rvm mount' to get more information on binary rubies.
Installing Ruby from source to: /home/kk_Ataka/.rvm/rubies/ruby-2.0.0-p0, this may take a while depending on your cpu(s)...
ruby-2.0.0-p0 - #downloading ruby-2.0.0-p0, this may take a while depending on your connection...
ruby-2.0.0-p0 - #extracted to /home/kk_Ataka/.rvm/src/ruby-2.0.0-p0 (already extracted)
ruby-2.0.0-p0 - #configuring
ruby-2.0.0-p0 - #compiling
ruby-2.0.0-p0 - #installing 
Retrieving rubygems-2.0.0
######################################################################## 100.0%
Extracting rubygems-2.0.0 ...
Removing old Rubygems files...
Installing rubygems-2.0.0 for ruby-2.0.0-p0 ...
Installation of rubygems completed successfully.
Saving wrappers to '/home/kk_Ataka/.rvm/bin'.
ruby-2.0.0-p0 - #adjusting #shebangs for (gem irb erb ri rdoc testrb rake).
ruby-2.0.0-p0 - #importing default gemsets, this may take time ...
Install of ruby-2.0.0-p0 - #complete 
```

```console
$ rvm list

rvm rubies

   ruby-1.8.7-p358 [ x86_64 ]
=* ruby-1.9.2-p318 [ x86_64 ]
   ruby-1.9.3-p125 [ x86_64 ]
   ruby-2.0.0-p0 [ x86_64 ]

# => - current
# =* - current && default
#  * - default
```

切り替えもできる。

```console
$ rvm use ruby-2.0.0
Using /home/kk_Ataka/.rvm/gems/ruby-2.0.0-p0
$ ruby -v
ruby -v
ruby 2.0.0p0 (2013-02-24 revision 39474) [x86_64-linux]
$ gem list

*** LOCAL GEMS ***

bigdecimal (1.2.0)
bundler (1.3.0.pre.8)
io-console (0.4.2)
json (1.7.7)
minitest (4.3.2)
psych (2.0.0)
rake (10.0.3, 0.9.6)
rdoc (4.0.0)
rubygems-bundler (1.1.0)
rvm (1.11.3.6)
test-unit (2.0.0.0)
```

あれ？こっちはbundlerのpreが入っとる。

bundle実行した時に警告？が出るなー。

```console
$ bundle install
The source :rubygems is deprecated because HTTP requests are insecure.
Please change your source to 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
```
