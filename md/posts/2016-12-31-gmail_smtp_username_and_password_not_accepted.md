---
layout: post
title: "Gmail経由でのstmp送信でUsername and Password not accepted 534-5.7.14"
description: ""
category: 
tags: [Gmail]
old_url: http://d.hatena.ne.jp/kk_Ataka/20161231/1484122766
---

## あらすじ

Rubyスクリプト内にてGmail経由でsmtp送信しようとしたら `Username and Password not accepted` と表示されてしまった。

何度も施行していると、「ログイン試行をブロックしました」というメールが届き、エラーも `534-5.7.14 <https://accounts.google.com/ContinueSignIn(以下略)` と変わった。

`smtp.rb` の `check_auth_response` メソッドでauthに失敗している模様。(該当メソッドでメールアドレスとパスワードを `puts` してみたけど、あってる=これを使用してブラウザログインはできる)

## 解決策

二段階認証設定をオンにし、アプリパスワードを発行。

自分のメールアドレスとアプリパスワードで認証するとメール送信できた。

- [【メール送信エラー】Net::SMTPAuthenticationError - 534-5.7.14 <https://accounts.google.com/ContinueSignIn ... - Qiita](http://qiita.com/mr-myself/items/d2911a6c77406c40eb9a)

ちょっと古いが、二段階認証かつアプリパスワード使用でも、そもそも無理という話もある。

- [Gmail 経由での SMTP メール送信が出来ない時の解決法 (ユーザー名とパスワードは合っているのに。。) - Qiita](http://qiita.com/Yinaura/items/6886682a607951a71bac)
