---
layout: post
title: "Ruby1.9.3のWebrickで出るCould not determine content-length...エラーを消す方法(2.0.0では解決済)"
description: ""
category:
tags: [Ruby, Rails]
---

## あらすじ

Redmineを起動している時に以下のようなログが大量に吐かれコンソールが埋め尽くされて困った。

{% highlight console %}
[yyyy-mm-dd ...] WARN Could not determine content-length of response body. Set content-length of the response or set Response#chunked = true
{% endhighlight %}

## 環境

- Ruby 1.9.3
- Redmine 2.3.1
  - Rails 3.2.13
  - WEBrick 1.3.1

## 参考サイト

- [Railsのログから"Could not determine content-length ..."とかでてるのを消す - Qiita [キータ]](http://qiita.com/y_uuki/items/0f8c093bd25eac3119a0)
- [Webrickが出す大量のログを抑止するには？ - QA@IT](http://qa.atmarkit.co.jp/q/63)
- [Ruby - Railsサーバーの WARN Could not determine content-length… のログを表示しないようにする - Qiita [キータ]](http://qiita.com/ysk_1031/items/e57852a07dc4ddef8dbe)
- [rails 3.1.1.rc1 emits warning for each assets when using ruby-1.9.3-rc1 · Issue #3164 · rails/rails · GitHub](https://github.com/rails/rails/issues/3164)
- [Bug #5737: WEBrick doesn't support keep alive connections for 204 and 304 responses - ruby-trunk - Ruby Issue Tracking System](https://bugs.ruby-lang.org/issues/5737)

## 解決方法

以下のパッチをあてる or 該当ファイルを変更する。

- [204-304-keep-alive.patch - ruby-trunk - Ruby Issue Tracking System](https://bugs.ruby-lang.org/attachments/2300/204_304_keep_alive.patch)

このパッチは取り込まれていて、最新版だとなおってるのかな？

→ **2.0.0 ではなおってた！**

- [ruby/lib/webrick/httpresponse.rb at ruby-2-0-0 · ruby/ruby · GitHub](https://github.com/ruby/ruby/blob/ruby_2_0_0/lib/webrick/httpresponse.rb)

{% highlight ruby %}
      # Keep-Alive connection.
      if @header['connection'] == "close"
        @keep_alive = false
      elsif keep_alive?
        if chunked? || @header['content-length'] || @status == 304 || @status == 204 || HTTPStatus.info?(@status)
          @header['connection'] = "Keep-Alive"
        else
{% endhighlight %}

ちなみに、 [Railsのissue](https://github.com/rails/rails/issues/3164) を見ると、みんな発生してた様子。

RFCにはこう書いてある模様。

- [Bug #5737: WEBrick doesn't support keep alive connections for 204 and 304 responses - ruby-trunk - Ruby Issue Tracking System](https://bugs.ruby-lang.org/issues/5737)

> So if you want to do keep-alive, even if you add a content length, you will always get a warning. RFC2616 Section 4.4 says:
>
> > 1.Any response message which "MUST NOT" include a message-body (such as the 1xx, 204, and 304 responses and any response to a HEAD request) is always terminated by the first empty line after the header fields, regardless of the entity-header fields present in the message
>
> I think this means that clients will know the length of the body, and clients can support keep-alive connections with no content-length for these types of responses.
