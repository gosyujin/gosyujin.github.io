---
layout: post
title: "iOSのUIWebViewのキャッシュがどういうタイミングでリセットされているのかわからんという話"
description: ""
category: 
tags: [iOS, iPhone]
---

## あらすじ

とあるWebサーバのファイルの内容を変えたとき、 UIWebView 経由でアクセスすると更新が反映されない現象が起こった。

また、戻るボタンも更新ボタンもなにもつけていなかったため、その状況でどうやったらキャッシュを捨てて新しいファイルを取得できるかわからなかった。

## 環境

- サーバ
  - apache バージョン失念
- クライアント
  - iOS 6.0 と 5.1 の UIWebView と Safari

### サーバの内容

変更したファイル `index.html`

    - <p>Hell World</p>
    + <p>Hello World</p>

とりあえず更新がわかるようにテキトウな文言で。

### 上記 index.html にアクセスした結果

- iPhone Safari
  - 更新された
- iPhone 独自アプリ内の UIWebView
  - **更新されない場合があった**
- 上記とは別の iPhone Safari
  - 更新された
- おまけ: PCからアクセスした場合(IEだったかな)
  - 更新された

試行回数が不十分なため完全ではなさそうだが、とりあえず UIWebView でのアクセス時は更新されたりされなかったり。(アプリのタスクを切ったり、電源ON/OFFしたりも試した)

Safari は確実に更新されたため、恐らく UIWebView が Safari とは違う風にキャッシュを持っていて、それが悪さをしているんじゃなかろうかと推測。

## 解法

というわけで、ソース内で明示的にキャッシュを削除すれば、クリーンな状態を保てるのでは。

### キャッシュポリシーの変更

#### 使用前

> NSURLRequest *request = [NSURLRequest requestWithURL:url];

#### 使用後

>   NSURLRequest *request = [NSURLRequest requestWithURL:url
>   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
>   timeoutInterval:60.0];

キャッシュポリシーは以下のものがある。

- NSURLRequestUseProtocolCachePolicy
- NSURLRequestReloadIgnoringLocalCacheData
  - (NSURLRequestReloadIgnoringCacheData が置き換わったもの)
- NSURLRequestReloadIgnoringLocalAndRemoteCacheData
- NSURLRequestReloadRevalidatingCacheData
- NSURLRequestReturnCacheDataElseLoad
- NSURLRequestReturnCacheDataDontLoad

名前が長い…。

キャッシュを無視するには `NSURLRequestReloadIgnoringLocalCacheData` を使えばよい。

### キャッシュ容量を 0 に

- [[XCODE] UIWebViewでHTML,CSS,JSなどをキャッシュさせない方法 - YoheiM .NET](http://www.yoheim.net/blog.php?q=20120912)

{% highlight objective-c %}
[[NSURLCache sharedURLCache] setMemoryCapacity:0];
{% endhighlight %}

### キャッシュ全消し

- [知ってると楽になるUIWebView関連6つのTips｜学習A4デスノート @ Cocos2d-x とかの勉強メモ](http://sarudeki.jp/fernweh/uiwebview/)
- [Objective-C - UIWebViewを使うときに気をつけていること - Qiita [キータ]](http://qiita.com/uro_uro_/items/d4e5fb66f2039090000f)

{% highlight objective-c %}
[[NSURLCache sharedURLCache] removeAllCachedResponses];
{% endhighlight %}

を呼べばキャッシュを全消しできるよう。

### ネットワーク情報を監視できるライブラリ

- [Cocoaの日々: [iOS] ネットワーク接続状況取得ライブラリを公開](http://cocoadays.blogspot.jp/2011/05/ios_25.html)
- [dev5tec/FBNetworkReachability · GitHub](https://github.com/dev5tec/FBNetworkReachability)

## 結果

今回は強引に `UIWebView#shouldStartLoadWithRequest:navigationType:` で毎回キャッシュを削除するようにした。

{% highlight objective-c %}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
  navigationType:(UIWebViewNavigationType)navigationType {

    [[NSURLCache sharedURLCache] removeAllCachedResponses];

(処理)

    // キャッシュの内容を取得して表示(文字コードはShift_JIS)
    NSCachedURLResponse *cachedData = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    NSData *data = [cachedData data];

    NSString *html = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
    NSLog(@"%@", html);

(以下略)
{% endhighlight %}

これで、画面遷移とホームで終了から再起動したとき、一応キャッシュを見る事はなくなったはず。

ただし、単純にこれだけを追加すると毎回問答無用でキャッシュを消すので速度の問題とかあるかも。

## TODO

- アタリはつけられたので、この辺のドキュメントを調べてみる
- iOS 7 ではどうなっているのか

## おまけ: ホームで終了した場合にアプリを終わらせる

また、上記の対応をしただけだと、 iPhone をホームボタンで終了した後、再度アプリを起動すると未更新のまま同じ画面が出てしまう…。

という事で、ホームで終了した場合、再起動時は問答無用ではじめからとするようにもした。

`PROJECT_NAME-Info.plist` というファイルの中に `Application does not run in background` (アプリケーションをバックグラウンドで走らせない) という項目があるのでこれを `YES` に。

ソースで見ると `UIApplicationExitsOnSuspend` が変わっていた。

{% highlight xml %}
        <key>UIApplicationExitsOnSuspend</key>
-       <false/>
+       <true/>
{% endhighlight %}
