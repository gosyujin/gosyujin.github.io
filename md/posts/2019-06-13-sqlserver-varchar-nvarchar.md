---
layout: post
title: "SQL Serverでnvarchar(x)のカラムにx文字入らないのはなぜ"
description: ""
category: 
tags: [SQL Server, 文字コード]
---

## あらすじ

SQL Serverにおける文字列型の長さは、nvarcharクラスを使っていればバイト数に関するあれこれは
SQL Server側で吸収してくれて、特に気にする必要ないと思ってたが違った。

## 環境

```sql
SELECT SERVERPROPERTY('productversion') as VERSION;
```

|VERSION|
|:---|
|14.0.1000.169|

## 事象

```sql
CREATE TABLE dbo.sampletable (
	nvc nvarchar(3)
);
```

例えば、`nvarchar(3)`カラムを持つテーブルを作ったら、以下のような長さのデータは全部INSERTできると考えていた。

- abc
- あいう
- ｱｲｳ
- 亜位宇

実際これらはINSERTできる。でもこれはINSERTできない。

- &#x20BB7;野家

## 原因と対策

サロゲート文字は1文字でデータ長2として扱われる模様。なので、SQL Serverの文字列型は

> 補助文字によって 2 つのバイト ペア (またはサロゲート ペア) が使用されるため、格納できる文字数は n よりも少なくなる場合があります。 

- nvarchar型を使う
- サロゲート文字がまざると定義した長さの最大値は入らない
    - 照合順序によっては`LEN`関数も正しくカウントされない
- カラムのサイズは想定したMAXデータ長×2で定義した方がよさげ(全部サロゲート文字の場合)
    - 文字数を正確にカウントしたい場合、SCの照合順序を使用する

> SC の照合順序を使用する場合、返される整数値では、UTF-16 サロゲート ペアが 1 文字としてカウントされます。

このあたりを気を付けた方が良いっぽい。

## 実際に確認してみる

### テーブル作成

```sql
CREATE TABLE dbo.sampletable( 
  id int NOT NULL IDENTITY (1, 1)
  , vc varchar (3)
  , nvc nvarchar(3)
  , altvc varchar (3) -- varcharからnvarcharに変えてみる
  , kakusu_nvc nvarchar(3) -- 照合順序をJapanese_Bushu_Kakusu_100_CI_AS_SCに設定してみる
); 

ALTER TABLE dbo.sampletable ALTER COLUMN altvc nvarchar(3); 
ALTER TABLE dbo.sampletable ALTER COLUMN kakusu_nvc nvarchar(3) COLLATE Japanese_Bushu_Kakusu_100_CI_AS_SC; 
```

出来上がったテーブルがこちら。

```sql
SELECT
  TABLE_SCHEMA               AS schema,        TABLE_NAME             AS table
  , COLUMN_NAME              AS column,        DATA_TYPE              AS type
  , CHARACTER_SET_NAME       AS character_set, COLLATION_NAME         AS collation
  , CHARACTER_MAXIMUM_LENGTH AS maximum_len,   CHARACTER_OCTET_LENGTH AS octet_len
FROM
  INFORMATION_SCHEMA.COLUMNS 
WHERE
  TABLE_SCHEMA = 'dbo'; 
```

|schema|table|column|typ|character_set|collation|maximum_len|octet_len|
|:---|:---|:---|:---|:---|:---|---:|---:|
|dbo|sampletable|id|int|||||
|dbo|sampletable|vc|varchar|**cp932**|Japanese_CI_AS|3|3|
|dbo|sampletable|nvc|nvarchar|UNICODE|Japanese_CI_AS|3|6|
|dbo|sampletable|altvc|nvarchar|UNICODE|Japanese_CI_AS|3|6|
|dbo|sampletable|kakusu_nvc|nvarchar|UNICODE|**Japanese_Bushu_Kakusu_100_CI_AS_SC**|3|6|

### データINSERT

コードブロックの中から1文字選んで3文字分INSERTしてみる。INSERT文の典型的な形は以下。

```sql
INSERT INTO dbo.sampletable VALUES (N'ぁぁぁ', N'ぁぁぁ', N'ぁぁぁ', N'ぁぁぁ');
```

1カラムずつINSERTしてもいいし、入らない場合は適当に入らないところを削ったりしてみる。

#### パターン1: U+3040～U+309F Hiragana 平仮名

- ぁぁぁ(U+3041)
    - いわゆるひらがな
    - varcharには3文字分入らない

#### パターン2: U+3400～U+4DBF CJK Unified Ideographs Extension A CJK統合漢字拡張A

- &#x3401;&#x3401;&#x3401;(U+3401)
    - いわゆる漢字
    - varcharには入るが???となってしまう

#### パターン3: U+FF00～U+FFEF Halfwidth and Fullwidth Forms 半角・全角形

- ｧｧｧ(U+FF67)
    - いわゆる半角カナ
    - 全部3文字分入る

#### パターン4: U+20000～U+2A6DF CJK Unified Ideographs Extension B CJK統合漢字拡張B

##### パターン4.1: CJK統合漢字拡張をB3文字分

- &#x20BB7;&#x20BB7;&#x20BB7;(U+20BB7)
    - サロゲート文字
    - 全部入らない
    - &#x20BB7;野家でも入らない
        - 野はU+91CE、屋はU+5BB6でどちらもCJK統合漢字

##### パターン4.2: CJK統合漢字拡張を1文字だけ

- &#x20BB7;(U+20BB7)
    - 一文字分なら全部入る
    - varcharは??となる
    - 1文字しか追加していないのに`LEN`および`DATALENGTH`では×2分確保されている
    - 照合順序が`Japanese_Bushu_Kakusu_100_CI_AS_SC`のカラムは`LEN`がこちらの想定通り戻ってくる

## 結果

上記のINSERT結果を`LEN`および`DATALENGTH`と共に取得した。

```sql
SELECT 
  vc           AS 'vc',  LEN(vc)         AS l1, DATALENGTH(vc)         AS d1
  , nvc        AS 'nvc', LEN(nvc)        AS l2, DATALENGTH(nvc)        AS d2
  , altvc      AS 'alt', LEN(altvc)      AS l3, DATALENGTH(altvc)      AS d3
  , kakusu_nvc AS 'kak', LEN(kakusu_nvc) AS l4, DATALENGTH(kakusu_nvc) AS d4
FROM dbo.sampletable;
```

|パターン|vc|l1|d1|nvc|l2|d2|alt|l3|d3|kak|l4|d4|
|---:|:---|---:|---:|:---|---:|---:|:---|---:|---:|:---|---:|---:|
|1  |×|||ぁぁぁ|3|6|ぁぁぁ|3|6|ぁぁぁ|3|6|
|2  |???|3|3|&#x3401;&#x3401;&#x3401;|3|6|&#x3401;&#x3401;&#x3401;|3|6|&#x3401;&#x3401;&#x3401;|3|6|
|3  |ｧｧｧ|3|3|ｧｧｧ|3|6|ｧｧｧ|3|6|ｧｧｧ|3|6|
|4.1|×|||×|||×|||×|||
|4.2|??|2|2|&#x20BB7;|2|4|&#x20BB7;|2|4|&#x20BB7;|**1**|4|

※ パターン列は便宜上くっつけた

`LEN`の仕様:

> 指定された文字列式の、末尾の空白を除いた文字数を返します。
>
> SC の照合順序を使用する場合、返される整数値では、UTF-16 サロゲート ペアが 1 文字としてカウントされます。

`DATALENGTH`の仕様:

> この関数では、式を表すために必要なバイト数が返されます。

## どの文字がやばいのか

やばいのはこの辺。

- [CJK統合漢字拡張B CJK Unified Ideographs Extension B U+20000～U+203FF](https://0g0.org/category/20000-2A6DF/1/) 
    - &#x20302; U+20302
- [CJK統合漢字拡張C CJK Unified Ideographs Extension C U+2A700～U+2AAFF](https://0g0.org/category/2A700-2B73F/1/)
    - &#x2A7DF; U+2A7DF
- [CJK統合漢字拡張D CJK Unified Ideographs Extension D U+2B740～U+2B81F](https://0g0.org/category/2B740-2B81F/1/)
    - &#x2B743; U+2B743
- [CJK統合漢字拡張E CJK Unified Ideographs Extension E U+2B820～U+2BC1F](https://0g0.org/category/2B820-2CEAF/1/)
    - &#x2BB5F; U+2BB5F
- [CJK互換漢字補助 CJK Compatibility Ideographs Supplement U+2F800～U+2FA1F](https://0g0.org/category/2F800-2FA1F/1/)
    - &#x2F801; U+2F801

※ &#x20BB7;野家の正式な方の&#x20BB7;(つちよし)もCJK統合漢字拡張Bに入っている。([U+20BB7](https://0g0.org/search/20BB7/))

あとこの辺。

- [顔文字 Emoticons U+1F600～U+1F64F](https://0g0.org/category/1F600-1F64F/1/)
    - &#x1F600; U+1F600
- [交通及び地図の記号 Transport And Map Symbols U+1F680～U+1F6FF](https://0g0.org/category/1F680-1F6FF/1/)
    - &#x1F680; U+1F680
- [補助記号及び絵文字 Supplemental Symbols and Pictographs U+1F900～U+1F9FF](https://0g0.org/category/1F900-1F9FF/1/)
    - &#x1F910; U+1F910
- [その他の記号及び絵文字 Miscellaneous Symbols And Pictographs U+1F300～U+1F5FF](https://0g0.org/category/1F300-1F5FF/1/)
    - &#x1F300; U+1F300

サロゲートペアになっていないこの辺は大丈夫。歴史的経緯がわからないけどCJK統合漢字拡張Aはセーフ。

- [平仮名 Hiragana U+3040～U+309F](https://0g0.org/category/3040-309F/1/)
    - &#x3042; U+3042
- [片仮名 Katakana U+30A0～U+30FF](https://0g0.org/category/30A0-30FF/1/)
    - &#x30A2; U+30A2
- [CJK統合漢字拡張A CJK Unified Ideographs Extension A U+3400～U+37FF](https://0g0.org/category/3400-4DBF/1/)
    - &#x3440; U+3440
- [CJK統合漢字 CJK Unified Ideographs U+4E00～U+51FF](https://0g0.org/category/4E00-9FFF/1/)
    - &#x5149; U+5149
- [半角・全角形 Halfwidth and Fullwidth Forms U+FF00～U+FFEF](https://0g0.org/category/FF00-FFEF/1/)
    - &#xFF67; U+FF67

## 参考

- [nchar と nvarchar (Transact-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/t-sql/data-types/nchar-and-nvarchar-transact-sql?view=sql-server-2017)
- [照合順序と Unicode のサポート - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/collations/collation-and-unicode-support?view=sql-server-2017#Supplementary_Characters)
- [列の照合順序の設定または変更 - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/collations/set-or-change-the-column-collation?view=sql-server-2017)
- [LEN (Transact-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/t-sql/functions/len-transact-sql?view=sql-server-2017)
- [DATALENGTH (Transact-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/t-sql/functions/datalength-transact-sql?view=sql-server-2017)
- [Unicode(ユニコード)とURLエンコード検索と変換サイト 0g0.org](https://0g0.org/)
- [JavaScriptでのサロゲートペア文字列のメモ - Qiita](https://qiita.com/YusukeHirao/items/2f0fb8d5bbb981101be0)
- [サロゲートペア文字とDB設計を考える | デーコムラボ](https://www.dcom-web.co.jp/lab/database/think_of_surrogate_pair_and_database_design)

