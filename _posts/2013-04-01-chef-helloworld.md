---
layout: post
title: " 入門Chef Solo - Infrastructure as Code を読みながらChef Soloで遊べるようになるまで"
description: ""
category: 
tags: [Ruby, StartUp, Chef]
---
{% include JB/setup %}

## あらすじ

Chefを触ってみたいと思いつつ、取っ掛かりを作るにはかなり用語が多いなーとウダウダしていたら、3/11にこんな本が出版されており。

- [Amazon.co.jp： 入門Chef Solo - Infrastructure as Code eBook: 伊藤直也: Kindleストア](http://www.amazon.co.jp/exec/obidos/ASIN/B00BSPH158/everlasting-22/ref=nosim/)

早速購入。

本書のはじめにはこんな事が書かれていました。

> 公式ドキュメントがあまりにしっかり書かれすぎていることもあって「はじめの一歩」としてどの辺りを知ればいいのか、つまり「普通に使う分にはこの程度知っていればOK」というのがどの辺りなのかを掴むのが難しい…というのが筆者の個人的な印象です。

はじめの一歩をどうしようか迷ってる場合オススメと……。

ではHello Worldしてみよう。

## 環境(Windows編)

- Windows XP
- Ruby 1.9.3
- Rubygems 1.8.24

## 手順

### Chef インストール

ネットワークに繋がっていないぼっち環境のため、vendor/cacheディレクトリに必要なGemをありったけ放り込んでbundle install。

{% highlight console %}
$ bundle install --local --path vendor/bundle
Installing erubis (2.7.0)
Installing highline (1.6.16)
Installing json (1.7.7)
Installing mixlib-log (1.4.1)
Installing mixlib-authentication (1.3.0)
Installing mixlib-cli (1.3.0)
Installing mixlib-config (1.1.2)
Installing win32-api (1.4.8)
Installing windows-api (0.4.2)
Installing windows-pr (1.2.2)
Installing win32-process (0.6.6)
Installing mixlib-shellout (1.1.0)
Installing net-ssh (2.6.6)
Installing net-ssh-gateway (1.2.0)
Installing net-ssh-multi (1.1)
Installing ipaddress (0.8.0)
Installing systemu (2.5.2)
Installing yajl-ruby (1.1.0)
Installing ohai (6.16.0)
Installing mime-types (1.21)
Installing rest-client (1.6.7)
Installing chef (11.4.0)
Using bundler (1.3.1)
{% endhighlight %}

### 構成 レポジトリ、クックブック、レシピ

Chefには `レポジトリ` , `クックブック` , `レシピ` という概念がある。

- レシピ: コード化された手順書
- クックブック: 特定レシピのデータをまとめる
- レポジトリ: クックブックを含めた全体

#### レポジトリ作成(コピー)

まずは、レポジトリのサンプルをGitHubから取得。

{% highlight console %}
$ git clone http://github.com/opscode/chef-repo.git
{% endhighlight %}

中身はこんな感じ。それぞれの役目はまだわからない。

- LICENSE
- README.md
- Rakefile
- certificates/
- chefignore
- config/
- cookbooks/
- data_bags/
- environments/
- roles/

#### クックブック作成

クックブックを作るためにはツール `knife` を使う。

`knife` の初期設定。 `knife` はChefをインストールすれば使えるようになっている。

{% highlight console %}
$ bundle exec knife -h
Usage: knife sub-command (options)
    -s, --server-url URL             Chef Server URL
    -k, --key KEY                    API Client Key
        --[no-]color                 Use colored output, defaults to enabled
    -c, --config CONFIG              The configuration file to use
        --defaults                   Accept default values for all questions
    -d, --disable-editing            Do not open EDITOR, just accept the data as is
    -e, --editor EDITOR              Set the editor to use for interactive commands
    -E, --environment ENVIRONMENT    Set the Chef environment
    -F, --format FORMAT              Which format to use for output
    -u, --user USER                  API Client Username
        --print-after                Show the data after a destructive operation
    -V, --verbose                    More verbose output. Use twice for max verbosity
    -v, --version                    Show chef version
    -y, --yes                        Say yes to all prompts for confirmation
    -h, --help                       Show this message
{% endhighlight %}

設定ファイルなど作成するために `knife configure` を実行。

色々聞かれるが、今はそのままでいい。

{% highlight console %}
$ bundle exec knife configure
WARNING: No knife configuration file found
Where should I put the config file? [C:/Documents and Settings/USER/.chef/knife.rb]
Please enter the chef server URL: [http://localhost:4000]
Please enter an existing username or clientname for the API: [USER] kk_Ataka
Please enter the validation clientname: [chef-validator]
Please enter the location of the validation key: [/etc/chef/validation.pem]
Please enter the path to a chef repository (or leave blank):
*****

You must place your client key in:
  C:/Documents and Settings/USER/.chef/kk_Ataka.pem
Before running commands with Knife!

*****

You must place your validation key in:
  C:/etc/chef/validation.pem
Before generating instance data with Knife!

*****
Configuration file written to C:/Documents and Settings/USER/.chef/knife.rb
{% endhighlight %}

初期設定が終わったので、さっき落としたレポジトリの中でクックブックを作る。

`knife cookbook create COOKBOOK_NAME -o COOKBOOK_DIR`

{% highlight console %}
$ bundle exec knife cookbook create hello -o cookbooks
** Creating cookbook hello
** Creating README for cookbook: hello
** Creating CHANGELOG for cookbook: hello
** Creating metadata for cookbook: hello
{% endhighlight %}

これで `chef-repo/cookbooks/hello` の中に以下のようなファイル。

- CHANGELOG.md
- README.md
- attributes/
- definitions/
- files/
- libraries/
- metadata.rb*
- providers/
- recipes/
- resources/
- templates/

`knife` コマンドも、生成されたファイルもまだ全然わからないけど、

1. レポジトリを作成
1. クックブックを作成

まではできたので、次はいよいよレシピを作成。

#### レシピ編集

すでにひな形はできている。(コメントだけだけど) `chef-repo/cookbooks/hello/recipes/default.rb`

{% highlight ruby %}
#
# Cookbook Name:: hello
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
{% endhighlight %}

上記ファイルに追記。

はじめはlogでHello Worldを吐くだけのレシピを作成。

{% highlight ruby %}
log "Hello World!"
{% endhighlight %}

### その他設定色々、動かすためにもう少し

レポジトリの直下 `chef-repo/` に どのレシピを実行するか指定するjsonファイルを作る。名前は `localhost.json` とした。

{% highlight json %}
// localhost.json
{
  "run_list" : [ "recipe[hello]" ]
}
{% endhighlight %}

同じくレポジトリの直下に、テンポラリディレクトリの設定などを記述する `solo.rb` を作る。

{% highlight ruby %}
# solo.rb
file_cache_path "C:/chef/tmp/chef-solo"
cookbook_path ["C:/chef/chef-repo/cookbooks"]
{% endhighlight %}

### 実行

…すると、Gemsが結構足りないのか、Load Errorが多発。

ffi がないって言われたり、ruby-wmiがないって言われたり、win32/serviceがないって言われたり…。

{% highlight console %}
$ bundle exec chef-solo -c solo.rb -j ./localhost.json
C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require':
cannot load such file -- win32/service (LoadError)
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/chef/vendor/bundle/ruby/1.9.1/gems/chef-11.4.0/lib/chef/provider/service/windows.rb:24:in `<top (required)>'
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/chef/vendor/bundle/ruby/1.9.1/gems/chef-11.4.0/lib/chef/providers.rb:77:in `<top (required)>'
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/chef/vendor/bundle/ruby/1.9.1/gems/chef-11.4.0/lib/chef.rb:25:in
`<top (required)>'
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/chef/vendor/bundle/ruby/1.9.1/gems/chef-11.4.0/lib/chef/application/solo.rb:19:in `<top (required)>'
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/rubies/Ruby-193-p0/lib/ruby/site_ruby/1.9.1/rubygems/core_ext/kernel_require.rb:45:in `require'
        from C:/chef/vendor/bundle/ruby/1.9.1/gems/chef-11.4.0/bin/chef-solo:23:in `<top (required)>'
        from C:/chef/vendor/bundle/ruby/1.9.1/bin/chef-solo:23:in `load'
        from C:/chef/vendor/bundle/ruby/1.9.1/bin/chef-solo:23:in `<main>'
{% endhighlight %}

色々調べてみる……。

- [windows - cannot load such file -- ruby-wmi (LoadError) & cannot load such file -- win32/service (LoadError) - Stack Overflow](http://stackoverflow.com/questions/12868121/cannot-load-such-file-ruby-wmi-loaderror-cannot-load-such-file-win32-s)
- [Common Errors - Chef - Opscode Open Source Wiki](http://wiki.opscode.com/display/chef/Common+Errors#CommonErrors-Nosuchfiletoloadrubywmi)

最終的にGemfileはこうなった。

{% highlight ruby %}
source :rubygems
source "http://rubygems.org"

gem "chef"
gem 'ffi'

gem "win32-service"
gem "ruby-wmi"
gem "windows-api"
gem "windows-pr"
gem "rdp-ruby-wmi"
{% endhighlight %}

満を辞して！

{% highlight console %}
$ bundle exec chef-solo -c solo.rb -j ./localhost.json
Starting Chef Client, version 11.4.0
[2013-03-22T17:32:30+09:00] WARN: unable to detect ip6address
Compiling Cookbooks...
Converging 1 resources
Recipe: hello::default
  * log[Hello World] action write

Chef Client finished, 1 resources updated
{% endhighlight %}

## 本当に何かインストールしてみる

ここからは、本当に何かをインストールしてみる。

……と同時に、サーバいじるんだからWindowsじゃなくていいよねということで構成変更。

## 環境(Linux編)

- Red Hat Linux 5.4
- Ruby 1.9.3
- Rubygems 1.8.23

## インストールテスト(zsh)

zshをchefでインストールしてみる。

ただし、外部に接続できないサーバなので、

1. zshのrpmをダウンロードして
1. サーバに転送
1. chefでは(サーバ内の)ローカルにあるrpmを指定しインストール

できるように準備。

`chef-solo/cookbooks/hello/recipes/default.rb` にzshを追加。

{% highlight ruby %}
package "zsh" do
  action   :install
  source   "/home/kk_Ataka/zsh-3.0.5-6.i386.rpm"
  provider Chef::Provider::Package::Rpm
end
log "Hello World"
{% endhighlight %}

通常は、 `action :install` だけで、chef側がrpmをよろしくやってくれるみたいだけど、今回はローカルのrpmを使うので、 `source` を指定してやる。

そして実行…あれ…なんかエラー出る。

{% highlight console %}
$ bundle exec chef-solo -c solo.rb -j localhost.json
The source :rubygems is deprecated because HTTP requests are insecure.
Please change your source to 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
Starting Chef Client, version 11.4.0
Compiling Cookbooks...
Converging 2 resources
Recipe: hello::default
  * package[zsh] action install
================================================================================
Error executing action `install` on resource 'package[zsh]'
================================================================================


Chef::Exceptions::Exec
----------------------
rpm  -U /home/kk_Ataka/zsh-3.0.5-6.i386.rpm returned 1, expected 0


Resource Declaration:
---------------------
# In /home/kk_Ataka/chef/chef-repo/cookbooks/hello/recipes/default.rb

  9: package "zsh" do
 10:   action   :install
 11:   source   "/home/kk_Ataka/zsh-3.0.5-6.i386.rpm"
 12:   provider Chef::Provider::Package::Rpm
 13: end
 14: log "Hello World"



Compiled Resource:
------------------
# Declared in /home/kk_Ataka/chef/chef-repo/cookbooks/hello/recipes/default.rb:9:in `from_file'

package("zsh") do
  provider Chef::Provider::Package::Rpm
  action [:install]
  retries 0
  retry_delay 2
  package_name "zsh"
  source "/home/kk_Ataka/zsh-3.0.5-6.i386.rpm"
  version "3.0.5-6"
  cookbook_name :hello
  recipe_name "default"
end



[2013-03-25T19:00:12+09:00] ERROR: Running exception handlers
[2013-03-25T19:00:12+09:00] ERROR: Exception handlers complete
Chef Client failed. 0 resources updated
[2013-03-25T19:00:12+09:00] FATAL: Stacktrace dumped to /home/kk_Ataka/chef/chef-repo/tmp/chef-solo/chef-stacktrace.out
[2013-03-25T19:00:12+09:00] FATAL: Chef::Exceptions::Exec: package[zsh] (hello::default line 9) had an error: Chef::Exceptions::Exec: rpm  -U /home/kk_Ataka/zsh-3.0.5-6.i386.rpm returned 1, expected 0
{% endhighlight %}

なんでだろ。あ、 **一般ユーザだから** か、そういえば？

{% highlight console %}
$ rpm  -U /home/kk_Ataka/zsh-3.0.5-6.i386.rpm
エラー: can't create transaction lock on /var/lib/rpm/__db.000
{% endhighlight %}

やはり。

{% highlight console %}
$ su
# bundle exec chef-solo -c solo.rb -j localhost.json
Starting Chef Client, version 11.4.0
Compiling Cookbooks...
Converging 2 resources
Recipe: hello::default
  * package[zsh] action install
      - install version 3.0.5-6 of package zsh

        * log[Hello World] action write

    Chef Client finished, 2 resources updated
{% endhighlight %}

いったー。

## インストールテスト(nginx)

次にnginxを入れてみる。

レシピはインストールするパッケージ毎に分けた方がいいみたいなんだけど、今回は仮なので同じレシピに詰め込んでいく。

{% highlight ruby %}
package "nginx" do
  action   :install
  source   "/var/package/nginx-1.2.7-1.el5.ngx.i386.rpm"
  provider Chef::Provider::Package::Rpm
end
{% endhighlight %}

chef実行！

{% highlight console %}
[2013-03-28T19:20:48+09:00] ERROR: Running exception handlers
[2013-03-28T19:20:48+09:00] ERROR: Exception handlers complete
Chef Client failed. 0 resources updated
[2013-03-28T15:20:48+09:00] FATAL: Stacktrace dumped to /home/kk_Ataka/chef/chef-repo/tmp/chef-solo/chef-stacktrace.out
[2013-03-28T19:20:48+09:00] FATAL: Chef::Exceptions::Exec: package[nginx] (hello::default line 18) had an error: Chef::Exceptions::Exec: rpm  -U /var/package/nginx-1.2.7-1.el5.ngx.i386.rpm returned 1, expected 0
{% endhighlight %}

だめ？何だこのエラー…直接rpmできるか確認してみるか。

{% highlight console %}
rpm -ivh /var/package/nginx-1.2.7-1.el5.ngx.i386.rpm
警告: /var/package/nginx-1.2.7-1.el5.ngx.i386.rpm: ヘッダ V3 RSA/SHA1 signature: NOKEY, key ID 7bd9bf62
エラー: 依存性の欠如:
        libpcre.so.0 は nginx-1.2.7-1.el5.ngx.i386 に必要とされています
{% endhighlight %}

あ、ライブラリが足りないのか。PCREをDLしてインストールする必要があるのね

まずはnginxとその依存ファイルをインストールするように書いてみた。

{% highlight ruby %}
package "pcre" do
  action   :install
  source   "/var/package/pcre-6.6-6.el5_6.1.i386.rpm"
  provider Chef::Provider::Package::Rpm
end

package "pcre-devel" do
  action   :install
  source   "/var/package/pcre-devel-6.6-6.el5_6.1.i386.rpm"
  provider Chef::Provider::Package::Rpm
end

package "nginx" do
  action   :install
  source   "/var/package/nginx-1.2.7-1.el5.ngx.i386.rpm"
  provider Chef::Provider::Package::Rpm
end
{% endhighlight %}

で、インストール。

{% highlight console %}
# bundle exec chef-solo -c solo.rb -j localhost.json
Starting Chef Client, version 11.4.0
Compiling Cookbooks...
Converging 4 resources
Recipe: hello::default
  * package[zsh] action install
    - install version 3.0.5-6 of package zsh

  * package[pcre] action install 
    - install version 6.6-6.el5_6.1 of package pcre

  * package[pcre-devel] action install
    - install version 6.6-6.el5_6.1 of package pcre-devel

  * package[nginx] action install
    - install version 1.2.7-1.el5.ngx of package nginx
{% endhighlight %}

はいった！んでnginxがあるかどうか確認…。

{% highlight console %}
# nginx -v
nginx version: nginx/1.2.7
{% endhighlight %}

ある！じゃあ起動。

{% highlight console %}
# /etc/init.d/nginx start
nginx を起動中:                                            [  OK  ]
{% endhighlight %}

きたーーー！

### service

今までレシピには `package` と `log` しか使っていなかった。

次に、 `service` の定義方法を確認。

serviceを定義する事でサービス周りの操作をできる。

例えば、サービス自動起動の設定はなんにもしないとこうなってる。

{% highlight console %}
# chkconfig --list | grep nginx
nginx           0:off   1:off   2:on    3:on    4:on    5:on    6:off
{% endhighlight %}

レシピのservice > `action` を `:disable` にして再インストールすると。

{% highlight ruby %}
service "nginx" do
  action   [ :disable ]
end
{% endhighlight %}

{% highlight console %}
  * package[nginx] action install (up to date)
  * service[nginx] action disable
    - disable service service[nginx]
{% endhighlight %}

サービスが無効になる。逆に `:enable`にしてみる。プラス、 `start` もつけてみる。

{% highlight ruby %}
service "nginx" do
  action   [ :enable, :start ]
end
{% endhighlight %}

{% highlight console %}
# chkconfig --list | grep nginx
nginx           0:off   1:off   2:off   3:off   4:off   5:off   6:off
{% endhighlight %}

{% highlight console %}
  * package[nginx] action install (up to date)
  * service[nginx] action enable
    - enable service service[nginx]

  * service[nginx] action start
    - start service service[nginx]
{% endhighlight %}

起動時にサービスが上がるようになり、chefコマンド実行後にnginxが起動状態となっている。

{% highlight console %}
# chkconfig --list | grep nginx
nginx           0:off   1:off   2:on    3:on    4:on    5:on    6:off
# /etc/init.d/nginx status
nginx (pid  20026) を実行中...
{% endhighlight %}

次に `supports` 。

{% highlight ruby %}
service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action   [ :enable, :start ]
end
{% endhighlight %}

これは、「他のリソースに、このサービスが使えるオプションを教える」ためのもの…らしい。

なくても動くが、指定しておくと吉という事。まだシチュエーションがよくわかっていない。

### template

設定ファイルを配備する。

例えば、 `/etc/nginx/nginx.conf` はそのまま入れるとこうなっている。

{% highlight console %}
# ls -l /etc/nginx/nginx.conf
-rw-r--r-- 1 root root 643  2月 12 22:57 /etc/nginx/nginx.conf
{% endhighlight %}

{% highlight nginx %}
# cat /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
{% endhighlight %}

これをパーミッションから内容から色々操作したい。

そんな時にレシピ `template` を追記。

{% highlight ruby %}
template "nginx.conf" do
  path     "/etc/nginx/nginx.conf"
  source   "nginx.conf.erb"
  owner    "root"
  group    "root"
  mode     0644
end
{% endhighlight %}

`source` が今回使うテンプレートとなる。ファイル名しか書いていないが、クックブック内の `templates/default/` 下が読まれる様子。

また、 `source` を書かないと、Chefが `nginx.conf.erb` を探しに行くみたい。この時の前半部 `nginx.conf` は template の nginx.conf から来ているんだろうか。

で、 `templates/default/nginx.conf.erb` を作成する。

{% highlight nginx %}
user            nginx;
worker_processes 1;
error_log       /var/log/nginx/error.log;
pid             /var/run/nginx.pid;

events {
  worker_connections 1024;
}

http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;
  server {
    listen      <%= node['nginx']['port'] %>;
    server_name localhost;
    location /  {
      root  /usr/share/nginx/html;
      index index.htm;
    }
  }
}
{% endhighlight %}

基本的には、思うままに設定ファイルを作成するだけ。

ただし、一点特徴として、設定ファイルの中に `Attribute` が使える。変数を埋め込んで展開できる。

上記のファイルでは `listen` の値を `<%= node['nginx']['port'] %>` としてある。

これはどこに定義しているかというと……。

レポジトリ直下に作っていた `localhost.json` に定義している。

{% highlight json %}
// localhost.json
{
  "nginx"    : { "port" : 8090 },
  "run_list" : [ "recipe[hello]" ]
}
{% endhighlight %}

これが使われる。

んで、templateを使ってchef実行！

{% highlight console %}
# bundle exec chef-solo -c solo.rb -j localhost.json
Starting Chef Client, version 11.4.0
Compiling Cookbooks...
Converging 6 resources
Recipe: hello::default
  * package[zsh] action install (up to date)
  * package[pcre] action install (up to date)
  * package[pcre-devel] action install (up to date)
  * package[nginx] action install (up to date)
  * service[nginx] action enable (up to date)
  * service[nginx] action start (up to date)
  * template[nginx.conf] action create
    - update template[nginx.conf] from 772e91 to acb62b
        --- /etc/nginx/nginx.conf       2013-03-29 19:05:50.000000000 +0900
        +++ /tmp/chef-rendered-template20130329-1313-3044nz     2013-03-29 19:05:56.000000000 +0900
        @@ -1,32 +1,21 @@
        -
        -user  nginx;
        -worker_processes  1;
        -
        -error_log  /var/log/nginx/error.log warn;
        -pid        /var/run/nginx.pid;
        -
        +user            nginx;
        +worker_processes 1;
        +error_log       /var/log/nginx/error.log;
        +pid             /var/run/nginx.pid;

         events {
        -    worker_connections  1024;
        +  worker_connections 1024;
         }

        -
         http {
        -    include       /etc/nginx/mime.types;
        -    default_type  application/octet-stream;
        -
        -    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
        -                      '$status $body_bytes_sent "$http_referer" '
        -                      '"$http_user_agent" "$http_x_forwarded_for"';
        -
        -    access_log  /var/log/nginx/access.log  main;
        -
        -    sendfile        on;
        -    #tcp_nopush     on;
        -
        -    keepalive_timeout  65;
        -
        -    #gzip  on;
        -
        -    include /etc/nginx/conf.d/*.conf;
        +  include      /etc/nginx/mime.types;
        +  default_type application/octet-stream;
        +  server {
        +    listen      8090;
        +    server_name localhost;
        +    location / {
        +      root  /usr/share/nginx/html;
        +      index index.htm;
        +    }
        +  }
         }
{% endhighlight %}

お、置き換わったっぽい。

{% highlight console %}
# ls -l /etc/nginx/nginx.conf
-rw-r--r-- 1 root root 392  3月 29 19:05 /etc/nginx/nginx.conf
{% endhighlight %}

644のroot:rootになってる。

中身は……。

{% highlight nginx %}
user            nginx;
worker_processes 1;
error_log       /var/log/nginx/error.log;
pid             /var/run/nginx.pid;

events {
  worker_connections 1024;
}

http {
  include      /etc/nginx/mime.types;
  default_type application/octet-stream;
  server {
    listen      8090;
    server_name localhost;
    location / {
      root  /usr/share/nginx/html;
      index index.htm;
    }
  }
}
{% endhighlight %}

置き変わってる。listen ポートも8090になってる。

`notifies` の話はまた今度。

### cookbook file

クックブック内のファイルをサーバの特定の場所に配備。

まず、クックブックの `files/default` ディレクトリにファイルを作る。

{% highlight console %}
# touch cookbooks/hello/files/default/README
# echo "this is readme file" >> cookbooks/hello/files/default/README
{% endhighlight %}

これをレシピに `cookbook_file` として記載。

{% highlight ruby %}
cookbook_file "/tmp/README" do
  mode 00444
end
{% endhighlight %}

{% highlight console %}
# bundle exec chef-solo -c solo.rb -j localhost.json
(略)
  * template[nginx.conf] action create (up to date)
  * cookbook_file[/tmp/README] action create
    - create a new cookbook_file /tmp/README
        --- /tmp/chef-tempfile20130329-2216-1jqt4bi     2013-03-29 23:41:59.000000000 +0900
        +++ /home/kk_Ataka/chef/chef-repo/cookbooks/hello/files/default/README     2013-03-29 23:37:45.000000000 +0900
        @@ -0,0 +1 @@
        +this is readme file

Chef Client finished, 1 resources updated
{% endhighlight %}

できてるかな？

{% highlight console %}
# ls -l /tmp/README
-r--r--r-- 1 root root 20  3月 29 23:41 /tmp/README
# cat /tmp/README
this is readme file
{% endhighlight %}

おーできてる。

他にも `source` , `owner` , `group` , `path` , `checksum` などを指定できる。

checksumは `SHA-256` が使われる。

{% highlight console %}
# sha256sum cookbooks/hello/files/default/README
ee55fd3276ac9361a6e632e100dba72bfa34c06f8feb2c3f8d8ae95f06941bf0  cookbooks/hello/files/default/README
{% endhighlight %}

ほい。これをレシピに指定。

{% highlight ruby %}
cookbook_file "/tmp/README" do
  mode 00444
  checksum "ee55fd3276ac9361a6e632e100dba72bfa34c06f8feb2c3f8d8ae95f06941bf0"
end
{% endhighlight %}

問題がなければ、何事もなく。checksumを誤ると……。

{% highlight ruby %}
cookbook_file "/tmp/README" do
  mode 00444
  checksum "hoge"
end
{% endhighlight %}

エラーとなる。

{% highlight console %}
# bundle exec chef-solo -c solo.rb -j localhost.json
Starting Chef Client, version 11.4.0
Compiling Cookbooks...

================================================================================
Recipe Compile Error in /home/kk_Ataka/chef/chef-repo/cookbooks/hello/recipes/default.rb
================================================================================


Chef::Exceptions::ValidationFailed
----------------------------------
Option checksum's value hoge does not match regular expression /^[a-zA-Z0-9]{64}$/


Cookbook Trace:
---------------
  /home/kk_Ataka/chef/chef-repo/cookbooks/hello/recipes/default.rb:49:in `block in from_file'
  /home/kk_Ataka/chef/chef-repo/cookbooks/hello/recipes/default.rb:47:in `from_file'


Relevant File Content:
----------------------
/home/kk_Ataka/chef/chef-repo/cookbooks/hello/recipes/default.rb:

 42:    group    "root"
 43:    mode     0644
 44:  #  notifies :reload, 'service[nginx]'
 45:  end
 46:
 47:  cookbook_file "/tmp/README" do
 48:    mode 00444
 49>>   checksum "hoge"
 50:  end
 51:


[2013-03-29T23:53:54+09:00] ERROR: Running exception handlers
[2013-03-29T23:53:54+09:00] ERROR: Exception handlers complete
Chef Client failed. 0 resources updated
[2013-03-29T23:53:54+09:00] FATAL: Stacktrace dumped to /home/kk_Ataka/chef/chef-repo/tmp/chef-solo/chef-stacktrace.out
[2013-03-29T23:53:54+09:00] FATAL: Chef::Exceptions::ValidationFailed: Option checksum's value hoge does not match regular expression /^[a-zA-Z0-9]{64}$/
{% endhighlight %}

### directory

そのもの、ディレクトリを作る または 削除する。レシピはこう。

{% highlight ruby %}
directory "/tmp/mydirectory" do
  mode 00755
  owner "kk_Ataka"
  action :create
end
{% endhighlight %}

`action` に作るか消すかを設定、 `:create` か `:delete` を指定。

{% highlight console %}
# bundle exec chef-solo -c solo.rb -j localhost.json
(略)
  * directory[/tmp/mydirectory] action create
    - create new directory /tmp/mydirectory
    - change mode from '' to '0755'
    - change owner from '' to 'kk_Ataka'
{% endhighlight %}

できた。

{% highlight console %}
# ls -l /tmp/
drwxr-xr-x  2 kk_Ataka root 4096  3月 29 23:03 mydirectory
{% endhighlight %}

ところで、レシピを記述する順番とかは意識する必要があるんだろうか。

- README を `/tmp/mydirectory` に置きたい
- `/tmp/mydirectory` はレシピで作る(今はない)

後でディレクトリを作る。

{% highlight ruby %}
cookbook_file "/tmp/mydirectory/README" do
  mode 00444
  checksum "ee55fd3276ac9361a6e632e100dba72bfa34c06f8feb2c3f8d8ae95f06941bf0"
end
directory "/tmp/mydirectory" do
  mode 00755
  action :create
end
{% endhighlight %}

結果、ダメ。

{% highlight console %}
[2013-03-29T23:11:39+09:00] ERROR: Running exception handlers
[2013-03-29T23:11:39+09:00] ERROR: Exception handlers complete
Chef Client failed. 0 resources updated
[2013-03-29T23:11:39+09:00] FATAL: Stacktrace dumped to /home/kk_Ataka/chef/chef-repo/tmp/chef-solo/chef-stacktrace.out
[2013-03-29T23:11:39+09:00] FATAL: Chef::Exceptions::EnclosingDirectoryDoesNotExist: cookbook_file[/tmp/mydirectory/README] (hello::default line 47) had an error: Chef::Exceptions::EnclosingDirectoryDoesNotExist: Parent directory /tmp/mydirectory does not exist.
{% endhighlight %}

先にディレクトリを作る。

{% highlight ruby %}
directory "/tmp/mydirectory" do
  mode 00755
  action :create
end
cookbook_file "/tmp/mydirectory/README" do
  mode 00444
  checksum "ee55fd3276ac9361a6e632e100dba72bfa34c06f8feb2c3f8d8ae95f06941bf0"
end
{% endhighlight %}

結果、いけた。

{% highlight console %}
  * directory[/tmp/mydirectory] action create
    - create new directory /tmp/mydirectory
    - change mode from '' to '0755'

  * cookbook_file[/tmp/mydirectory/README] action create
    - create a new cookbook_file /tmp/mydirectory/README
        --- /tmp/chef-tempfile20130329-4457-myq1xs      2013-03-29 23:13:10.000000000 +0900
        +++ /home/kk_Ataka/chef/chef-repo/cookbooks/hello/files/default/README     2013-03-29 23:37:45.000000000 +0900
        @@ -0,0 +1 @@
        +this is readme file

Chef Client finished, 2 resources updated
# ls -l /tmp/
合計 8
drwxr-xr-x  2 root root 4096  3月 29 23:13 mydirectory
# ls -l /tmp/mydirectory/
合計 4
-r--r--r-- 1 root root 20  3月 29 23:13 README

# cat /tmp/mydirectory/README
this is readme file
{% endhighlight %}

- 存在しないディレクトリを作ったりという事は、Chefではよろしくやってくれない
- 必要なディレクトリなどは先に作っておく必要がある

ということかな。

### user

ユーザ作成。 `action` は `:create` の場合省略していいみたい。削除する場合は `:remove` 修正もできるが一旦置いておく。

{% highlight ruby %}
user "ataka_man" do
  action   :create
  comment  "from_chef"
  home     "/home/ataka_man"
  shell    "/bin/bash"
  password nil
end
{% endhighlight %}

{% highlight console %}
  * user[ataka_man] action create
    - create user user[ataka_man]
{% endhighlight %}

### group

グループもユーザ同様作成できる。

{% highlight ruby %}
group "xenoblade" do
  action  :create
  gid     999
  members ["ataka_man"]
end
{% endhighlight %}

{% highlight console %}
  * group[xenoblade] action create
    - create group[xenoblade]
{% endhighlight %}

### bash

bashを使う事も出来る。が、「あるべき状態」に持っていくのがたいへんなので、ご利用は計画的に。

{% highlight ruby %}
bash "make_echofile_in homedir" do
  user "kk_Ataka"
  group "kk_Ataka"
  cwd "/"
  environment "HOGE_PATH" => "/home/kk_Ataka/"
  code <<-EOC
    cd $HOGE_PATH
    touch hello
    chmod 777 hello
    echo "#!/bin/bash" >> hello
    echo "echo hello"  >> hello
  EOC
  creates "/home/kk_Ataka/hello"
end
{% endhighlight %}

`cwd` はカレントワーキングディレクトリ、 `environment` は環境変数を指定できる。

`code` に実行したいコマンドを記述。

ここでは、

1. `environment` に記載したパスに移動
1. hello ファイルを作成
1. 実行権限変更
1. echo文追加

している。

最後の `creates` は **creates に定義したコマンドがある(実行できる)場合は、このリソースを実行しない** という判断のために使用される。

上記のレシピを実行すると、初回は

{% highlight console %}
  * bash[make_echofile_in homedir] action run
    - execute "bash"  "/tmp/chef-script20130329-11001-k8nowp"
{% endhighlight %}

実行されるが、2回目以降は

{% highlight console %}
  * bash[make_echofile_in homedir] action run
{% endhighlight %}

こうなる。2回目以降は /home/kk_Ataka/hello が実行できるから、リソースを実行しない事になっている。

しかし、 `creates` をコメントアウトすると

{% highlight console %}
  * bash[make_echofile_in homedir] action run
    - execute "bash"  "/tmp/chef-script20130329-11473-1bf7sg9"
{% endhighlight %}

{% highlight console %}
  * bash[make_echofile_in homedir] action run
    - execute "bash"  "/tmp/chef-script20130329-xxxxx-xxxxxxx"
{% endhighlight %}

何度もexecuteされる。helloファイルも作成され続ける。

ここまでで、本書の2, 3, 9-13, 15辺りをひと通り触った事になる。
