---
layout: post
title: "Eclipseの動的Webプロジェクトから別プロジェクト(自作ライブラリ)を参照する"
description: "Eclipseのライブラリの参照のさせ方"
category: 
tags: [Eclipse]
---

## あらすじ

- 同じワークスペース上にあるsampleプロジェクトからutilプロジェクトのメソッドを呼び出しているソースがある
- ビルドは通っているが、実際に該当ロジックを動作させた時に`ClassNotFoundException`あるいは`NoClassDefFoundError`が出る

## 環境

- Eclipse 4.7
- WAS Liberty 19.0.0.1

## 本文

- ビルド・パスを通しただけだったのでWTP起動時に依存プロジェクトを一緒に配備できていなかった
- プロジェクト右クリック -> プロパティ -> デプロイメント・アセンブリー(Deployment Assembly)
    - 呼び出し先のプロジェクトを追加する。(古いEclipseだとJava EE Module Dependencies)
- ビルドして再び実行するとうまくいった。
- sampleプロジェクトの.projectファイルに以下の値が追加されていた。

```java
<projects>
  <project>util</project>
</projects>
```

- 「問題」タブには警告は出てない(多すぎてカットされている？)
- 「マーカー」タブには警告がバッチリ出てた

>クラスパス・エントリー /util は、エクスポートまたは公開されません。実行時に ClassNotFoundExceptions が発生する可能性があります。  sampleP/sampleクラスパス依存性バリデーター・メッセージ<br>

## 参考

- [EclipseでWebアプリを作っていて別プロジェクトを参照している場合の注意点 - wyukawa's diary](https://wyukawa.hatenablog.com/entry/20100731/1280585793)
- [動的WebプロジェクトからJavaプロジェクトを参照する - シュンツのつまづき日記](https://gloryof.hatenablog.com/entry/20130217/1361085501)
- [java - Javaのビルド・パス - ライブラリー(L) - Web app ライブラリー に、別プロジェクトを追加する方法 - スタック・オーバーフロー](https://ja.stackoverflow.com/questions/14779/java%E3%81%AE%E3%83%93%E3%83%AB%E3%83%89-%E3%83%91%E3%82%B9-%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%83%BCl-web-app-%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%83%BC%E3%81%AB-%E5%88%A5%E3%83%97%E3%83%AD%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%82%92%E8%BF%BD%E5%8A%A0%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95)
- [Dynamic Web Projectで任意の場所からライブラリを追加する方法 - marsのメモ](https://masanobuimai.hatenadiary.org/entry/20120125/1327503272)
- [JavaEE 7をやってみよう。 Webデプロイメントアセンブリー - ひこぽんのーと](http://nagamitsu1976.hatenadiary.jp/entry/2015/10/10/152908)

