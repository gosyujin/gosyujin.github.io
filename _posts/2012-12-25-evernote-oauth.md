---
layout: post
title: "自作EvernoteスクリプトをOAuth対応する"
description: ""
category: 
tags: [Ruby, Evernote, OAuth]
---
{% include JB/setup %}

## あらすじ

結構前に、Evernoteの認証方法がOAuthになるので、変更してくださいねーというメールがEvernoteからきていた。

[ユーザ名とパスワードによる認証から OAuth 認証への移行 - Evernote Developers](http://dev.evernote.com/intl/jp/documentation/cloud/chapters/Transition.php)

そのまま従来のスクリプトを動かしていると、認証エラーになるので、OAuth認証ができるように修正した。

主に自分用メモ。

## 環境

- Ruby 1.8.7

Evernoteスクリプトは自分しか使っていない。

## 参考サイト

- [認証 - Evernote Developers](http://dev.evernote.com/intl/jp/documentation/cloud/chapters/Authentication.php#devtoken)

## 手順

- [サンドボックス用のデベロッパトークンを取得 »](https://sandbox.evernote.com/api/DeveloperToken.action) ログイン必要
- [テストの完了後、プロダクション用のデベロッパトークンを取得 »](https://www.evernote.com/api/DeveloperToken.action) ログイン必要

![img](/images/EvernoteOAuth-0.jpg)
![img](/images/EvernoteOAuth-1.jpg)

他の人が使っていない、自分だけで使っている場合は以降の箇所だけ修正すればよい。

## 修正箇所

上記のDeveloperTokenをソース上で取得できるようにする。(今まで使っていたuserid、パスワードはいらない)以下では、Pitを使ってtokenなどを別出ししているので、そこを修正。

{% highlight ruby %}
         user = Pit.get("evernote", :require => {
+            "developerToken" => "your evernote token.",
         })
{% endhighlight %}

従来は、 `userStore.authenticate()` で認証を通して、 `authenticationToken` を使うようにしていたが、このくだりを **まるまるカット** 。

この `authenticationToken` を `developerToken` に置き換えてやる。

{% highlight ruby %}
         # 認証
-        @auth = auth(user, userStore)
-        @authToken = @auth.authenticationToken
-       
+        @authToken = user["developerToken"]
+
{% endhighlight %}

で、一個だけ困ったのが、認証結果からuserのshardIdを取ってきてnoteStoreUrlを生成していた箇所。

まるまるカットされたので、どうやって取得するのかな？　と思ったら、userStoreに `getNoteStoreUrl(token)` というメソッドがあるので、これを使えば良い。

{% highlight ruby %}
         noteStoreUrlBase = "https://#{evernoteHost}/edam/note/"
-        noteStoreUrl = noteStoreUrlBase + @auth.user.shardId
+        noteStoreUrl = userStore.getNoteStoreUrl(@authToken)
         noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
         noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
         @noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
{% endhighlight %}

これだけで、とりあえず動くようにはなった！