---
layout: post
title: "WEB+DB PRESS vol.82を参考にHubotと戯れてみた"
description: ""
category: 
tags: [node.js, Hubot]
---
{% include JB/setup %}

## あらすじ

最近よくHubotという単語を聞くのでちょっといじってみたかったが、要素技術的に普段全然使わないものが多くてけっこう敷居が高かった。

そんな折、WEB+DB PRESS vol.82にちょうどHubot特集が掲載されていたのでこれ幸いと読み進めてみた。

というわけで、以下の内容は「Hubotの環境を整えてHerokuにデプロイ、idobataに常駐させる」ところまでの作業備忘録。

idobataに云々以外の詳しい説明はWEB+DB PRESSのほうがくわしいよ。

## 環境構築

node.jsとnpm(Node Package Manager)をインストールする。

{% highlight console %}
$ sudo yum install nodejs npm
(略)
$ node -v 
v0.10.29
$ npm -v
1.3.6
{% endhighlight %}

npmでhubotとcoffee-scriptをインストールする。

オプションの-gはグローバルなパスにインストール。

{% highlight console %}
$ sudo npm install -g hubot coffee-script
(略)
/usr/bin/hubot -> /usr/lib/node_modules/hubot/bin/hubot
coffee-script@1.8.0 /usr/lib/node_modules/coffee-script
└── mkdirp@0.3.5

hubot@2.8.1 /usr/lib/node_modules/hubot
├── optparse@1.0.4
├── log@1.4.0
├── scoped-http-client@0.9.8
├── coffee-script@1.6.3
└── express@3.3.4 (methods@0.0.1, fresh@0.1.0, cookie-signature@1.0.1, range-parser@0.0.4, buffer-crc32@0.2.1, cookie@0.1.0, mkdirp@0.3.5, debug@2.0.0, commander@1.2.0, send@0.1.3, connect@2.8.4)
$ hubot -v
2.8.1
$ coffee -v
CoffeeScript version 1.8.0
{% endhighlight %}

## bot初期化

{% highlight console %}
$ hubot --create webhubot
Creating a hubot install at webhubot
Copying /usr/lib/node_modules/hubot/src/scripts/events.coffee -> /home/test/webhubot/scripts/events.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/google-images.coffee -> /home/test/webhubot/scripts/google-images.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/help.coffee -> /home/test/webhubot/scripts/help.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/httpd.coffee -> /home/test/webhubot/scripts/httpd.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/maps.coffee -> /home/test/webhubot/scripts/maps.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/ping.coffee -> /home/test/webhubot/scripts/ping.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/roles.coffee -> /home/test/webhubot/scripts/roles.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/pugme.coffee -> /home/test/webhubot/scripts/pugme.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/rules.coffee -> /home/test/webhubot/scripts/rules.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/translate.coffee -> /home/test/webhubot/scripts/translate.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/youtube.coffee -> /home/test/webhubot/scripts/youtube.coffee
Copying /usr/lib/node_modules/hubot/src/scripts/storage.coffee -> /home/test/webhubot/scripts/storage.coffee
Copying /usr/lib/node_modules/hubot/src/templates/Procfile -> /home/test/webhubot/Procfile
Copying /usr/lib/node_modules/hubot/src/templates/package.json -> /home/test/webhubot/package.json
Copying /usr/lib/node_modules/hubot/src/templates/README.md -> /home/test/webhubot/README.md
Copying /usr/lib/node_modules/hubot/src/templates/gitignore -> /home/test/webhubot/gitignore
Copying /usr/lib/node_modules/hubot/src/templates/hubot-scripts.json -> /home/test/webhubot/hubot-scripts.json
Copying /usr/lib/node_modules/hubot/src/templates/external-scripts.json -> /home/test/webhubot/external-scripts.json
Copying /usr/lib/node_modules/hubot/src/templates/bin/hubot -> /home/test/webhubot/bin/hubot
Copying /usr/lib/node_modules/hubot/src/templates/bin/hubot.cmd -> /home/test/webhubot/bin/hubot.cmd
Renaming /home/test/webhubot/gitignore -> /home/test/webhubot/.gitignore
{% endhighlight %}

hubotコマンドを実行するとエラーが出たけどRedisが入ってないよエラーという事なので、とりあえず問題なさげ。
今のところ永続的なデータは使わない。

{% highlight console %}
$ cd webhubot/
$ bin/hubot
hubot-scripts@2.5.15 node_modules/hubot-scripts
└── redis@0.8.4

hubot@2.8.1 node_modules/hubot
├── optparse@1.0.4
├── log@1.4.0
├── scoped-http-client@0.9.8
├── coffee-script@1.6.3
└── express@3.3.4 (methods@0.0.1, fresh@0.1.0, range-parser@0.0.4, cookie-signature@1.0.1, buffer-crc32@0.2.1, cookie@0.1.0, mkdirp@0.3.5, debug@2.0.0, commander@1.2.0, send@0.1.3, connect@2.8.4)
Hubot> [Mon Sep 01 2014 17:22:26 GMT+0900 (JST)] ERROR Error: listen EADDRINUSE
  at errnoException (net.js:904:11)
  at Server._listen2 (net.js:1042:14)
  at listen (net.js:1064:10)
  at net.js:1146:9
  at dns.js:72:18
  at process._tickCallback (node.js:419:13)

[Mon Sep 01 2014 17:22:26 GMT+0900 (JST)] ERROR [Error: Redis connection to localhost:6379 failed - connect ECONNREFUSED]
{% endhighlight %}

hubotコマンドも実行できた。

{% highlight console %}
Hubot> hubot translate me こんにちは
Hubot> " こんにちは" is Japanese for " Hello "
{% endhighlight %}

## スクリプト作成

`HUBOTROOT/scripts`の下に`hello.coffee`を作成する。

{% highlight coffeescript %}
$ cat scripts/hello.coffee
module.exports = (robot) ->
  robot.respond /hello (.+)/i, (msg) ->
    msg.send "Hello #{msg.match[1]}"
{% endhighlight %}

hubotを実行してみる。

{% highlight console %}
Hubot> hubot hello ataka
Hubot> Hello ataka
Hubot> hubot hello kk_Ataka
Hubot> Hello kk_Ataka
{% endhighlight %}

helloコマンドできた！

## 公式リポジトリのスクリプトを使う

公式リポジトリのスクリプトはcreateした段階でnode_modulesディレクトリに格納される。

これらを読み込むにはhubot-scripts.jsonに追記をする。今回はgithubのアクティビティを取得できるスクリプトgithub-activity.coffeeを追加してみる。

{% highlight console %}
$ cat hubot-scripts.json
["shipit.coffee", "github-activity.coffee"]
{% endhighlight %}

依存があるので、npmでインストールする。

{% highlight coffeescript %}
  4 # Dependencies:$
  5 #   "date-utils": ">=1.2.5"$
  6 #   "githubot": "0.4.x"$
{% endhighlight %}

{% highlight console %}
$ npm install date-utils --save
npm http GET https://registry.npmjs.org/date-utils
npm http 200 https://registry.npmjs.org/date-utils
npm http GET https://registry.npmjs.org/date-utils/-/date-utils-1.2.16.tgz
npm http 200 https://registry.npmjs.org/date-utils/-/date-utils-1.2.16.tgz
date-utils@1.2.16 node_modules/date-utils
$ npm install githubot --save
npm http GET https://registry.npmjs.org/githubot
npm http 200 https://registry.npmjs.org/githubot
npm http GET https://registry.npmjs.org/githubot/-/githubot-1.0.0-beta2.tgz
npm http 200 https://registry.npmjs.org/githubot/-/githubot-1.0.0-beta2.tgz
npm http GET https://registry.npmjs.org/async
npm http GET https://registry.npmjs.org/scoped-http-client
npm http 200 https://registry.npmjs.org/async
npm http GET https://registry.npmjs.org/async/-/async-0.2.10.tgz
npm http 200 https://registry.npmjs.org/async/-/async-0.2.10.tgz
npm http 200 https://registry.npmjs.org/scoped-http-client
githubot@1.0.0-beta2 node_modules/githubot
├── scoped-http-client@0.9.8
└── async@0.2.10
{% endhighlight %}

`hubot repo show`でリポジトリ確認。

{% highlight console %}
Hubot> hubot repo show jekyllrb-ja/jekyllrb-ja.github.io
Hubot> https://github.com/jekyllrb-ja/jekyllrb-ja.github.io
Hubot> [27/08 10:33 -> kk_Ataka] Merge pull request #263 from tmkoikee/update-index.md

index.md の本家への追従
Hubot> [26/08 22:57 -> tomohiro koike] index.md の本家への追従
Hubot> [26/08 10:17 -> kk_Ataka] Merge pull request #260 from tmkoikee/update-pagination-md

pagination.mdを本家に追従
Hubot> [26/08 10:17 -> kk_Ataka] Merge pull request #261 from tmkoikee/update-migrations.md

migrations.md の本家への追従
Hubot> [26/08 10:16 -> kk_Ataka] Merge pull request #262 from tmkoikee/update-installation.md

installation.mdを本家に追従
{% endhighlight %}

できた！

## idobataに登録

https://github.com/idobata/hubot-idobata#readme を参考に…。


{% highlight console %}
$ npm install hubot-idobata --save
(略)
hubot-idobata@0.1.0 node_modules/hubot-idobata
├── pusher-client@0.2.2 (eventemitter2@0.4.14, underscore@1.7.0, ws@0.4.32)
└── request@2.34.0 (json-stringify-safe@5.0.0, aws-sign2@0.5.0, forever-agent@0.5.2, tunnel-agent@0.3.0, qs@0.6.6, oauth-sign@0.3.0, node-uuid@1.4.1, mime@1.2.11, tough-cookie@0.12.1, form-data@0.1.4, hawk@1.0.0, http-signature@0.10.0)
{% endhighlight %}

環境変数`HUBOT_IDOBATA_API_TOKEN`にidobataのページから取得したトークンを格納し、hubotコマンド実行。

{% highlight console %}
$ export HUBOT_IDOBATA_API_TOKEN=6c5360hogehoge...
$ bin/hubot --adapter idobata
Your bot on Idobata is named as 'robo'.
But this hubot is named as 'Hubot'.
To respond to mention correctly, it is recommended that HUBOT_NAME=robo is configured.
{% endhighlight %}

ん、`HUBOT_NAME`もidobataに登録したものにする？

{% highlight console %}
$ export HUBOT_NAME=robo
{% endhighlight %}

## herokuに登録

上記のままだと、セッション切ったらロボが死んじゃうのでherokuで永遠の命を与える。

今度は https://github.com/idobata/hubot-idobata#deploying-to-heroku から https://github.com/github/hubot/blob/master/docs/deploying/heroku.md を参考に…。

まずはheroku toolbeltをインストール(heroku Gemはこれに置き換わる模様)。PATHを通すのを忘れずに。

{% highlight console %}
$ wget -qO- https://toolbelt.heroku.com/install.sh | sh
This script requires superuser access to install software.
You will be prompted for your password by sudo.
[sudo] password for kk_Ataka:
Add the Heroku CLI to your PATH using:
$ echo 'PATH="/usr/local/heroku/bin:$PATH"' >> ~/.profile
Installation complete
(略 / PATH通し)
$ heroku version
heroku-toolbelt/3.10.5 (x86_64-linux) ruby/2.1.0
{% endhighlight %}

herokuコマンドが入った。ログインしよう。

{% highlight console %}
$ heroku login
Enter your Heroku credentials.
Email: メールアドレス
Password (typing will be hidden):
Authentication successful.
{% endhighlight %}

はじめに作ったwebhubotディレクトリを登録しよう。

{% highlight console %}
$ cd webhubot/
$ git add 必要なファイル
$ git com 'First commit'
{% endhighlight %}

herokuアプリケーションを作成。コマンドラインからもできるのか。
createコマンドでリネームすると、適当な名前がつくので好きな名前にリネーム。

{% highlight console %}
$ heroku create
Creating young-refuge-9975... done, stack is cedar
http://young-refuge-9975.herokuapp.com/ | git@heroku.com:young-refuge-9975.git
Git remote heroku added
$ heroku apps:rename webhubot
Renaming young-refuge-9975 to webhubot... done
http://webhubot.herokuapp.com/ | git@heroku.com:webhubot.git
Git remote heroku updated
{% endhighlight %}

create, renameした段階でgit remote herokuが登録されている模様。

{% highlight console %}
$ git remote -v
heroku  git@heroku.com:webhubot.git (fetch)
heroku  git@heroku.com:webhubot.git (push)
{% endhighlight %}

https://github.com/idobata/hubot-idobata#deploying-to-heroku の2に戻りhubotとidobataの連携を登録。
APIトークンとNAME。

{% highlight console %}
$ heroku config:set HUBOT_IDOBATA_API_TOKEN=6c536hogehoge
Setting config vars and restarting webhubot... done, v3
HUBOT_IDOBATA_API_TOKEN: 6c53600hogehoge
$ heroku config:set HUBOT_NAME=robo
Setting config vars and restarting webhubot... done, v4
HUBOT_NAME: robo
{% endhighlight %}

Procfileのコマンドを変更。

{% highlight console %}
web: bin/hubot -a idobata
{% endhighlight %}

Gitコミットしてherokuにpush

{% highlight console %}
$ git add Procfile
$ git com "Mod Procfile's using adapter"
$ git push heroku master
Initializing repository, done.
Counting objects: 28, done.
Delta compression using up to 2 threads.
Compressing objects: 100% (23/23), done.
Writing objects: 100% (28/28), 11.20 KiB, done.
Total 28 (delta 2), reused 0 (delta 0)

-----> Node.js app detected

       PRO TIP: Avoid using semver ranges starting with '>' in engines.node
       See https://devcenter.heroku.com/articles/nodejs-support

-----> Requested node range:  >= 0.8.x
-----> Resolved node version: 0.10.31
-----> Downloading and installing node
-----> Exporting config vars to environment
-----> Installing dependencies

       > ws@0.4.32 install /tmp/build_74b7efb5-41da-4761-92c4-2a5ed07865d9/node_modules/hubot-idobata/node_modules/pusher-client/node_modules/ws
       > (node-gyp rebuild 2> builderror.log) || (exit 0)

       make: Entering directory `/tmp/build_74b7efb5-41da-4761-92c4-2a5ed07865d9/node_modules/hubot-idobata/node_modules/pusher-client/node_modules/ws/build'
         CXX(target) Release/obj.target/bufferutil/src/bufferutil.o
         SOLINK_MODULE(target) Release/obj.target/bufferutil.node
         SOLINK_MODULE(target) Release/obj.target/bufferutil.node: Finished
         COPY Release/bufferutil.node
         CXX(target) Release/obj.target/validation/src/validation.o
         SOLINK_MODULE(target) Release/obj.target/validation.node
         SOLINK_MODULE(target) Release/obj.target/validation.node: Finished
         COPY Release/validation.node
       make: Leaving directory `/tmp/build_74b7efb5-41da-4761-92c4-2a5ed07865d9/node_modules/hubot-idobata/node_modules/pusher-client/node_modules/ws/build'
       date-utils@1.2.16 node_modules/date-utils

       githubot@1.0.0-beta2 node_modules/githubot
       ├── scoped-http-client@0.9.8
       └── async@0.2.10

       hubot@2.8.1 node_modules/hubot
       ├── optparse@1.0.4
       ├── log@1.4.0
       ├── scoped-http-client@0.9.8
       ├── coffee-script@1.6.3
       └── express@3.3.4 (methods@0.0.1, fresh@0.1.0, range-parser@0.0.4, cookie-signature@1.0.1, buffer-crc32@0.2.1, cookie@0.1.0, mkdirp@0.3.5, commander@1.2.0, debug@2.0.0, send@0.1.3, connect@2.8.4)

       hubot-scripts@2.5.15 node_modules/hubot-scripts
       └── redis@0.8.4

       hubot-idobata@0.1.0 node_modules/hubot-idobata
       ├── request@2.34.0 (json-stringify-safe@5.0.0, forever-agent@0.5.2, qs@0.6.6, aws-sign2@0.5.0, tunnel-agent@0.3.0, oauth-sign@0.3.0, node-uuid@1.4.1,
mime@1.2.11, form-data@0.1.4, tough-cookie@0.12.1, http-signature@0.10.0, hawk@1.0.0)
       └── pusher-client@0.2.2 (eventemitter2@0.4.14, underscore@1.7.0, ws@0.4.32)
-----> Caching node_modules directory for future builds
-----> Cleaning up node-gyp and npm artifacts
-----> Building runtime environment
-----> Discovering process types
       Procfile declares types -> web

-----> Compressing... done, 6.9MB
-----> Launching... done, v5
       http://webhubot.herokuapp.com/ deployed to Heroku

To git@heroku.com:webhubot.git
 * [new branch]      master -> master
{% endhighlight %}

これで、heroku上でロボが生きはじめた。

## 永遠の命

herokuの変数`HEROKU_URL`に今回createしたアプリのURL `http://webhubot.herokuapp.com/` を登録する。

{% highlight console %}
$ heroku config:set HEROKU_URL=http://webhubot.herokuapp.com
Setting config vars and restarting webhubot... done, v7
HEROKU_URL: http://webhubot.herokuapp.com
{% endhighlight %}

これで「hubotが」定期的にURLを叩いてherokuのアイドリング状態を回避してくれるらしい。

ってことはこの設定はhubot側で使われるのかな？(他のherokuにデプロイしたWebアプリケーションでは？調べてない)
