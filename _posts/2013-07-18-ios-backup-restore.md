---
layout: post
title: "iOSのバックアップ/リストアで残るもの/消えるもの それを編集する手段"
description: ""
category: 
tags: [iPhone, iOS]
---

## あらすじ

iOSのバックアップ/リストア周りでえらいハメられたので、まとめてみた。

iOS 7 が出るとどうなってしまうのか…。

## バックアップの方式

iTunesの「概要」画面から選べる

1. iCloudにバックアップ
1. このコンピュータにバックアップ
  - そのまま
  - ローカルのバックアップを暗号化

あまり意識していなかったんだけど、iCloudバックアップは以下の条件を満たす時に実行される模様

- Wi-Fi 経由でインターネットに接続されている(MUST)
- 電源に接続されている
- 画面がロックされている

中でも、Wi-Fiだけは確実に満たす必要がある。(3G回線では、手動でiCloud同期もできない)

[iOS：コンテンツのバックアップと復元方法](http://support.apple.com/kb/ht1766?viewlocale=ja_JP&locale=ja_JP)

## バックアップされる内容

SandboxとKeyChainの大きく2つに分けられる

### Sandboxの内容

- [Cocoaの日々: [Info] 特定のファイルをiCloudバックアップ対象外にする](http://cocoadays.blogspot.jp/2011/11/info-icloud.html)
- [[XCODE] iPhone iOSのディレクトリ構成について学んだ - YoheiM技術やらずに終われまテン](http://d.hatena.ne.jp/yoheiM/20110227)
- [アプリケーションディレクトリの構造とアクセス方法 - プログラミングノート](http://d.hatena.ne.jp/ntaku/20110104/1294146555)

- `/var/mobile/Applications/01234567-890A-BCDE-FGHI-JKLMNOPQRSTU(ランダム文字列)/` 下のファイルがバックアップマシンに保存されたりされなかったり、 **基本的には** 以下の階層のバックアップと定義してあるものがそのまま保存される
  - `Documents/` バックアップ、アプリに関わる重要なファイル置き場
  - `Library/`
    - `Caches/` 非バックアップ、アプリで使用するが消えても大丈夫(また作れる)なファイル置き場
    - `Preferences/` バックアップ、アプリの設定ファイル置き場
  - `tmp/` 非バックアップ、一時ファイル置き場
- **基本的** じゃない場合が、 **このコンピュータにバックアップ ローカルのバックアップを暗号化** した時
  - 「ローカルのバックアップを暗号化」を選んだ時にユーザが入力したパスワードで暗号化され、保存される

どんなファイルが入っているかはXcodeの `Organizer => 任意の端末 => Applications => 任意のアプリケーション` の Data file in Sandboxで確認できる。

### KeyChainの内容

- [Cocoaの日々: [iOS] Keychain Services とは](http://cocoadays.blogspot.jp/2011/02/ios-keychain-services.html)
- [復元が不完全！？iPhoneバックアップで認証情報が復元できない理由とバックアップのオススメ設定 ｜ 情報科学屋さんを目指す人のメモ](http://did2memo.net/2012/10/02/iphone-how-to-backup-and-restore-key-chain/)

- 内容はバックアップマシンに保存されるが、 **暗号化** されている
- 暗号化されたKeyChain情報を複合化するための鍵は **基本的には** 暗号化したiOS端末から外に出ない
  - そのため、同じマシンでバックアップ/リストアをすると…
    - バックアップ ... KeyChain情報をバックアップマシンに格納
    - リストア ... 暗号化されたKeyChain情報が端末に戻ってくる
    - 同一端末なので、複合化するための鍵は持っている
    - パスワードとか復活できる
  - 一方、機種変更時などで、新端末にリストアすると…
    - バックアップ ... KeyChain情報をバックアップマシンに格納
    - リストア ... 暗号化されたKeyChain情報が端末に戻ってくる？(戻ってくることすらないのかな？確認方法がわからん)
    - 端末が異なるので、複合化するための鍵が **ない**
    - パスワードとか入れ直し…
- **基本的** じゃない場合が、 **このコンピュータにバックアップ ローカルのバックアップを暗号化** した時
  - この時、鍵もバックアップマシンに保存され、 **全部丸ごと暗号化** される
    - 「ローカルのバックアップを暗号化」を選んだ時にユーザが入力したパスワードで暗号化される

## バックアップ方法

上記の仕様でよろしくやってくれる。

## バックアップ除外方法

かといって、全部一括でバックアップとして外部サーバにあげられると困るファイルもあるはず。(著作権、個人情報、etc)

なので、そういうファイルはあらかじめバックアップ対象から除外しておく必要がある。

方法はiOSのバージョンによって異なる。

現時点では、 `iOS 5.1 以降` と `iOS 5.0.1` で場合分けした対応が必須みたい。

- [Technical Q&A QA1719: Technical Q&A QA1719](https://developer.apple.com/library/ios/qa/qa1719/_index.html)
- [iphone - NSURLIsExcludedFromBackupKey can not be set correctly - Stack Overflow](http://stackoverflow.com/questions/10836134/nsurlisexcludedfrombackupkey-can-not-be-set-correctly)

### iOS 5.0

そんなものはない。

### iOS 5.0.1

上記のdeveloper.apple.comのサンプルベタ貼り。

{% highlight objc %}
#import <sys/xattr.h>

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}
{% endhighlight %}

### iOS 5.1 以降

上記のdeveloper.apple.comのサンプルベタ貼り。

{% highlight objc %}
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                          forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}
{% endhighlight %}

## 注意点

addSkipBackupAttributeToItemAtURLメソッドの引数になっているNSURLにおいては、iOS 5.0.1 と 5.1 以降で渡す時のフォーマットが違う。

こんな文字列があった時、

    filePath = "/var/mobile/Applications/ランダム文字列/Documents/Settings.xml"

- iOS 5.0.1 `[NSURL URLWithString:filePath]` で渡す
- iOS 5.1 以降 `[NSURL fileURLWithPath:filePath]` で渡す

違いはこうなるみたい。スキームが付加される？(詳しく調べていない)

    [NSURL URLWithString:filePath]
    => /var/mobile/Applications/ランダム文字列/Documents/Settings.xml
    [NSURL fileURLWithPath:filePath]
    => file://localhost/var/mobile/Applications/ランダム文字列/Documents/Settings.xml
