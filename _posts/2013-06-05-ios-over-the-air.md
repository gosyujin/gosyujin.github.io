---
layout: post
title: "Over-the-Airという形式でiOSアプリのインストールを試みるが失敗する場合がある"
description: ""
category: 
tags: [iPhone, iOS]
---
{% include JB/setup %}

## あらすじ

iOSアプリをサーバに置いてそこからインストールできるようにしたかった。

- 結果、Over-the-Airという方式でインストール環境を作り、インストールできるようなったので手順のメモ
- と、なぜか失敗する端末もあるので、後半にその調査メモ(とりあえず、インストールはできたが、根本原因がわからん)

## インストール環境構築手順

### 参考サイト

- [iOS用アプリのAdHoc版を作る（Xcode） ｜ MUSHIKAGO APPS MEMO](http://mushikago.com/i/?p=2083)
- [iPadな日記 : AdHoc配布のやり方](http://blog.livedoor.jp/arumisoft/archives/12055981.html)
- [iOSアプリのAd-Hoc install (Over-the-Air, HTTP経由) がなんかよくわからんけど失敗する、という時はとにかくログを見るべしという話 - 愛と勇気と缶ビール](http://d.hatena.ne.jp/zentoo/20121024/1351097392)

### 前提

- iOS端末実機にXcode経由でアプリがビルドができる状態になっている事
- Webサーバ構築済で It works!! できる事

まだよくわかってないところもあるので、以下は必要ない手順、ファイルも多いかも。。。

別の作業と混同している可能性も。

### 前準備

#### CertificateSigningRequest.certSigningRequest 準備

はじめに `CertificateSigningRequest.certSigningRequest` をMac上で作成する

- `キーチェインアクセス` を起動
- `キーチェインアクセス -> 証明書アシスタント -> 認証局に証明書を要求...` を選択
  - メールアドレス: メアド入力
  - 通称: (なんでもいい？)
  - 要求の処理: `ディスクに保存` にチェック、 `鍵ペア情報を指定` にチェック
- そのまま続ける(鍵ペア情報はデフォルトのまま)
  - 鍵のサイズ: 2048ビット
  - アルゴリズム: RSA
- `CertificateSigningRequest.certSigningRequest` が作成される(次で使う)

#### Destribution用Certificates 作成

実機にインストールできるという事は、Developer用のCertificateは作成済のはず。今回はDestribution用を作る。

- [Apple Developer](https://developer.apple.com/) から iOS Apps へ
- `Certificates -> All(なんでもいい) -> +アイコン` で新しくCertificatesを作る
- `Select Type` : `App Store and Ad Hoc` を選択
  - 1個作ったらそれ以上作れない？ 改めて見に行ったらdisable状態で選択できなかったので、以降は記憶で
- `CertificateSigningRequest.certSigningRequest` を選択
- 作成されたDistribution Certificateをダウンロードしておく: `ios_distribution.cer`

#### Destribution用Provisioning Profile 作成

実機にインストールできるという事は、Developer用の以下略。

- 引き続き [Apple Developer](https://developer.apple.com/) の iOS Apps 
- `Provisioning Profiles -> All(なんでもいい) -> +アイコン` で新しくProvisioning Profileを作る
- `Select Type` : `Ad Hoc` を選択
- `Configure` : `Select App ID` App ID を選択するが、前提で使っている実機にインストールする時に使っているProvisioning Profileと同じ App ID を選択
- `Configure` : `Select certificates` 上で作成した時のDestribution用のCertificateファイルがあるはずなのでそれを選ぶ
- `Configure` : `Select devices` インストールしたいデバイスを選ぶ
- `Generate` : Profile Nameを入力
- 作成されたDestribution Provisioning Profile をダウンロードしておく: `PROJECT_NAME.mobileprovision`

ここまでで作ったファイルは、なんかうまくいかない時に使う **かも** 。

### アプリ側準備

#### Provisioning Profileインストール

※ ここは、サーバに `PROJECT_NAME.mobileprovision` を配備し、サーバ経由でインストールする方法もあるっぽい。

- Xcodeからビルドしたいプロジェクトを起動する
- `Organizer -> Devices -> LIBRARY -> Provisioning Profiles` に上で作った `PROJECT_NAME` のProvisioning Profileがある事を確認する
  - また、status が `Valid profile` になっている事を確認する
  - キーチェインへの登録とかがうまくいってないと、statusが 〜not found〜 みたいになる場合がある
- インストールしたい端末と Xcode を接続する
- `Organizer -> Devices -> 接続した端末 -> Provisioning Profiles` に `PROJECT_NAME` がある事を確認する
  - なければ、LIBRARYのProvisioning Profileからドラッグ＆ドロップしたりして持ってくる

#### ipaファイル作成

- 引き続きXcode
- Organizerからプロジェクトに戻りBuild Settingsへ
  - Code Signing Identity を `iPhone Distribution:` へ変更(必要？)
- `Product -> Archive` を選択
- アーカイブ化が成功したら `Organizer -> Archives` 画面が起動する
  - 作成されたアーカイブを選択し `Distribute...` 選択
  - `Select the method of distribution` : `Save for Enterprise or Ad-Hoc Deployment` 選択
  - `Choose an Identity to sign with` : https://developer.apple.com で作成した iOS Distribution が存在するはずなので、それを選択
  - `Save as` : 保存場所とファイル名を選択、 `Save for Enterprise Distribution` にチェックを入れる
    - `Application URL` : ipaファイルを配備する時のフルパスを入力する
      - 例: IPが `xx.xx.xx.xx` であるサーバの `DOCUMENT_ROOT/ipa/helloworld.ipa` に置くとしたら `http://xx.xx.xx.xx/ipa/helloworld.ipa`
      - Title以下は適当で(アイコンの設定とかなので、とりあえずインストールしたいだけの場合はTitle以外空白でもいい)
- `helloworld.ipa` と `helloworld.plist` が作成される

### ダウンロードページ準備

※ 作らなくても、Safari等から決められたUrlを直叩きすればインストールできる。…が、長くて直叩きはめんどい。

index.htmlとして、以下のようなリンクを持つページを作成する。

{% highlight html %}
(略)
<body>
<a href="itms-services://?action=download-manifest&url=PLIST_FULL_PATH">Download !!</a>
</body>
{% endhighlight %}

- `PLIST_FULL_PATH` : plistファイルを配備する時のフルパスを入力する(ipaファイルと同じ所に置く)
  - 例: IPが `xx.xx.xx.xx` であるサーバの `DOCUMENT_ROOT/ipa/helloworld.plist` に置くとしたら `http://xx.xx.xx.xx/ipa/helloworld.plist`

### サーバ配備

- サーバに以下のファイルを配備する。
  - `helloworld.ipa`
  - `helloworld.plist`
  - `index.html`

{% highlight console %}
  $ cp index.html DOCUMENT_ROOT/
  $ cp helloworld.ipa DOCUMENT_ROOT/ipa/
  $ chmod 755 DOCUMENT_ROOT/ipa/helloworld.ipa 
  $ cp helloworld.plist DOCUMENT_ROOT/ipa/
  $ chmod 755 DOCUMENT_ROOT/ipa/helloworld.plist
{% endhighlight %}

ダウンロードするのでアクセス権限を変更しておく。

### アクセス、インストール

- 端末から http://xx.xx.xx.xx/ へアクセスし、indexのリンクを叩く
- `"xx.xx.xx.xx"により"PROJECT"がインストールされます` と表示されるので、インストールを選択
- **うまくいけば** インストール成功

## うまくいかない場合

ここからが本題。

大体うまくいくんだけど、一部うまく場合がある。なんでかがわからない。

### パターン1

`iOS Deployment Target` のバージョンより低いバージョンの端末でインストールしようとした場合、エラーダイアログとともに失敗する。

これは凡ミスなので、TargetのiOSバージョンを下げてやればよい。

### パターン2

未遭遇だが、Provisioning Profileが正常にインストールされていない場合などもこけるはず。

設定アプリの一般からプロファイルを確認。

### パターン3(未解決)

これで困った。

- Safariにて、index.htmlに記載されたリンクを叩きインストール開始
- 端末の画面がSafariからホーム画面に遷移
- アイコンが現れ、 **待機中...** と表示される
- そこで止まる！
  - エラーなし、警告なしでずっと待機中のまま

iOSのバージョンとかにもよるのかと思ったが、違うっぽい。インストールできてる端末もあるし、Provisioning Profileも入ってるから端末の問題と思われる。

- iOS 5.0.1: インストール成功した
- iOS 5.1.1: インストール成功した
- iOS 6.0.1: **このエラーでインストールできなかった**
- ↑とは別のiOS 6.0.1: **インストール成功した**

内部のログとか見れないかと調べていると、2通りの方法で調べられた。

1. Xcodeの `Organizer -> 端末 -> Console`
1. Appleから `iPhone 構成ユーティリティ` アプリをダウンロード

どっちも端末とMacを接続すれば使える。

…で、確認してみたら以下のようなログが延々と出ていた。

{% highlight console %}
May xx xx:xx:xx iOS端末名 com.apple.launchd[1] (com.apple.ubd) <Notice>: (com.apple.ubd) Throttling respawn: Will start in 1 seconds
May xx xx:xx:xx iOS端末名 com.apple.launchd[1] (com.apple.ubd) <Notice>: (com.apple.ubd) Throttling respawn: Will start in 1 seconds
May xx xx:xx:xx iOS端末名 com.apple.launchd[1] (com.apple.ubd) <Notice>: (com.apple.ubd) Throttling respawn: Will start in 1 seconds
May xx xx:xx:xx iOS端末名 com.apple.launchd[1] (com.apple.ubd) <Notice>: (com.apple.ubd) Throttling respawn: Will start in 1 seconds
May xx xx:xx:xx iOS端末名 com.apple.launchd[1] (com.apple.ubd) <Notice>: (com.apple.ubd) Throttling respawn: Will start in 1 seconds
(略)
{% endhighlight %}

うーん、なんだろうこれ。

とりあえずエラーメッセージでググってみた。

launchdはプロセスの起動を制御するデーモンプロセス。

- [柔らか鍛冶屋: iOS: launchd](http://yawarakakajiya.blogspot.jp/2011/01/ios-launchd.html)
- [Undocumented Mac OS X：第1回　initを置き換えるlaunchd【前編】 (2/3) - ITmedia エンタープライズ](http://www.itmedia.co.jp/enterprise/articles/0704/26/news009_2.html)

こやつがubdを1秒毎に呼ぼうとしてる？

ubdとはなんぞや…。

- [What is "ubd"? — Process safety information — MacInside (Beta)](http://www.macinside.info/process.php?name=ubd)

> "ubd" is the Ubiquity Server Process.

何者なんだ…。OSXの方でなにやらエラーログを出しまくるという現象あり。

- [Ubiquityの大量エラーログ: Apple サポートコミュニティ](https://discussionsjapan.apple.com/thread/10106396?start=15&tstart=0)
- [Mobile Documentsフォルダが勝手に書き換えられる: Apple サポートコミュニティ](https://discussionsjapan.apple.com/message/100633645#100633645)

iCloud関係なの？確かにログインはした事あるけど、今はログアウト済なんだよなあ。

また、iPhone5のバッテリー持ちが4よりもひどいという所ではまったく同じログを吐いている人も。

- [iPhone 5 battery life is way worse than...: Apple Support Communities](https://discussions.apple.com/message/20379541#20379541)

ただし、決定打ではない…。

困り果てているところへこんな情報。(OSXっぽいけど)

- [com.apple.ubd problem - OSx86 10.8 (Mountain Lion) - InsanelyMac Forum](http://www.insanelymac.com/forum/topic/281143-comappleubd-problem/)

> This message would repeat in the logs every 10 seconds. 
> And would continue to repeat even after the offending application had been force quit. 
> A quick search for com.apple.ubd shows it is the iCloud synchronization daemon.

- アプリケーションをあらかたkillしてみる？
  - 念のため端末自体も再起動してみる
  - 再起動後、ダメ元でもう一度インストールしてみる
      - インストールされた
      - **なんで！？**

## しかも

正常にインストールできるようになってからも、インストール失敗した端末だけは依然として

{% highlight console %}
May xx xx:xx:xx iOS端末名 com.apple.launchd[1] (com.apple.ubd) <Notice>: (com.apple.ubd) Throttling respawn: Will start in 1 seconds
{% endhighlight %}

ログは出続けている…。

インストールできない問題と、このエラーメッセージは関係ないの！？

数ある内の一台だけ…なぜ。 
