---
layout: post
title: "GradleのresValueで値をリソースに設定する"
description: ""
category: 
tags: [Android, Gradle]
old_url: http://d.hatena.ne.jp/kk_Ataka/20170228/1488631327
---

## あらすじ

FacebookのAPIを使うために `facebookAppId` を取得したが、このAPI Keyを設定ファイル( `AndroidManifest.xml` )外に追い出すのに苦労した。

Gradle力が低いので、もっと良いやり方があるかもしれない。

- [スタートガイド - Android SDK](https://developers.facebook.com/docs/android/getting-started)

> 1.strings.xmlファイルを開きます。パスの例:/app/src/main/res/values/strings.xml。
> 2.新しい文字列を、facebook_app_idの名前とFacebookアプリIDとともに追加します。

## やりたいこと

- `facebookAppId` を `gradle.properties` に定義したい
- `AndroidManifest.xml` に `gradle.properties` から参照した文字列を埋め込みたい
- ただし、プロパティに定義したKeyは数値のみ(文字数値入り混じったKeyなら問題ない)

## manifestPlaceholdersに登録して参照(うまくいかなかった)

- `gradle.properties`
    - キーを書いた

```
facebookAppId=123456711111111
```

- `build.gradle`
    - `productFlavors` に `getProperty("facebookAppId")` と記載し、 `gradle.properties` から値を呼び出した

```
    productFlavors {
        develop {
            manifestPlaceholders = [
                                    facebook_app_id: getProperty("facebookAppId")]
            略
        }
    }
```

- `AndroidManifest.xml`

```xml
        <meta-data
            android:name="com.facebook.sdk.ApplicationId"
            android:value="${facebook_app_id}" />
```

これ、確かに参照はできるんだけどFacebookSDKの中でKeyが数値とみなされて `applicationId cannot be null` となってしまった。

そして、 `build.gradle` の中で何とか文字列に変換して渡そうとしてもうまくいかなかった…。

## resValueに登録して参照(うまくいった)

- [Android facebook applicationId cannot be null - Stack Overflow](http://stackoverflow.com/questions/16156856/android-facebook-applicationid-cannot-be-null)

同じような事をした人がおり、その回答は `resValue` でリソースとして登録すればいけるというものだったので試したところうまくいった。

- `gradle.properties`
    - 変更なし
- `build.gradle` 
    - 参照のしかたを `resValue` に変更した
    - これで `@string/〜` の形式でアクセスできるようになり、そして文字列としてFacebookSDKに渡されるようなので、無事にKeyが通った

```
    productFlavors {
        develop {
            resValue("string", "facebook_app_id", getProperty("facebookAppId"))
            略
        }
    }
```

- `AndroidManifest.xml`

```xml
        <meta-data
            android:name="com.facebook.sdk.ApplicationId"
            android:value="@string/facebook_app_id" />
```
