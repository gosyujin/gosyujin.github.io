---
layout: post
title: SQL Serverでの照合順序の確認方法
description: 
category: 
tags: [SQL Server]
---

## あらすじ

SQLServerでは文字コード、照合順序は特に指定がなければ「規定値」が設定されるらしい。

- [サロゲートペア文字とDB設計を考える | デーコムラボ](https://www.dcom-web.co.jp/lab/database/think_of_surrogate_pair_and_database_design)
- [SQL ServerにUnicodeの文字列を格納する方法 - 大人になったら肺呼吸](http://d.hatena.ne.jp/replication/20100101/1267972905)
- [SQLServerへのデータ格納時の文字コード（コードページ）について - 大人になったら肺呼吸](http://d.hatena.ne.jp/replication/20091009/1255092494)
- [SQL Server で照合順序 Japanese_CI_AS どこ消えた？あった。 | 技術的な何か。](http://level69.net/archives/24331)
- [SQL Serverにおける日本語文字列の取り扱いで躓いた話 - ShouN-7's tech blog](https://np8zkmjc63pmcc09.qrunch.io/entries/dQLi6gqoqEls1u6a) 

とりわけAzure環境下で英語→日本語切り替えとかすると躓く模様。

でも、そもそも規定値ってどこで確認するのという話。

## 環境

- SQL Server 14.0.1000.169

## まとめ

- 特に指定なしでDB/テーブルを作成する場合は規定値の照合順序(Collation)を使う
- 照合順序を変更しても、既に作成済のユーザーデータベースのテーブルの照合順序は変わらない
    - システムテーブル内は変わる
    - ユーザーテーブルは`ALTER DATABASE`で別途変更する必要がある
- 確認は`INFORMATION_SCHEMA.COLUMNS`ビューで行う

## 手順A(SQL Serverのシステム情報スキーマビューから確認する)

`INFORMATION_SCHEMA.COLUMNS`ビューに欲しい情報全部あった。

```sql
SELECT
  TABLE_CATALOG
  , TABLE_SCHEMA
  , TABLE_NAME
  , COLUMN_NAME
  , DATA_TYPE
  , CHARACTER_MAXIMUM_LENGTH
  , CHARACTER_OCTET_LENGTH
  , CHARACTER_SET_NAME
  , COLLATION_NAME 
FROM
  INFORMATION_SCHEMA.COLUMNS;
```

|TABLE_CATALOG|TABLE_SCHEMA|TABLE_NAME|COLUMN_NAME|DATA_TYPE|CHARACTER_MAXIMUM_LENGTH|CHARACTER_OCTET_LENGTH|CHARACTER_SET_NAME|COLLATION_NAME|
|:---|:---|:---|:---|:---|---:|---:|:---|:---|
|SAMPLE_INSTANCE|SAMPLE_SCHEMA|SAMPLE_TABLE|ID|varchar|3|3|cp932|Japanese_CI_AS|
|SAMPLE_INSTANCE|SAMPLE_SCHEMA|SAMPLE_TABLE|NAME|nvarchar|10|20|UNICODE|Japanese_CI_AS|
|SAMPLE_INSTANCE|SAMPLE_SCHEMA|SAMPLE_TABLE|ADDRESS|nvarchar|25|50|UNICODE|Japanese_CI_AS|
|SAMPLE_INSTANCE|SAMPLE_SCHEMA|SAMPLE_TABLE|UPDATE_DATE|date|||||

## 手順B(頑張る場合)

### とあるユーザーテーブルのカラムの照合順序を調べる

いきなりカラム(`sys.columns`)の内容を見てもどれがどれだかわからないので、順番に追っていく。

#### スキーマのIDを取得する

```sql
SELECT
  name
  , schema_id 
FROM
  sys.schemas 
WHERE
  name = 'SAMPLE_SCHEMA'; 
```

|name|schema_id|
|:---|---:|
|SAMPLE_SCHEMA|9|

#### スキーマIDをキーにスキーマ内のテーブルを取得する

```sql
SELECT
  schema_id
  , name
  , object_id 
FROM
  sys.tables 
WHERE
  schema_id = 9 
ORDER BY
  name ASC; 
```

|schema_id|name|object_id|
|---:|:---|---:|
|9|SAMPLE_TABLE|1430296111|
|9|SAMPLE_TABLE2|1430296166|
|以下略|||

#### オブジェクトIDをキーにカラムのcollation_nameを取得する

```sql
SELECT
  object_id
  , name
  , collation_name 
FROM
  sys.columns 
WHERE
  object_id = '1430296111'; 
```

|object_id|name|collation_name|
|---:|:---|:---|
|1430296111|NAME|Japanese_CI_AS|
|1430296111|UPDATE_DATE|(NULL)|
|以下略|||

文字列が入っているカラム(`Japanese_CI_AS`)と日付が入っているカラム(NULL)の照合順序がわかった。

`Japanese_CI_AS`が規定値なのだろう。

### SQL Serverの規定値の設定を調べる

#### サポートされている照合順序を取得する(LIKEで絞って日本語だけ)

- [sys.fn_helpcollations (TRANSACT-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/system-functions/sys-fn-helpcollations-transact-sql?view=sql-server-2017)

```sql
SELECT
  name
  , description 
FROM
  sys.fn_helpcollations() 
WHERE
  name LIKE 'Japanese%'; 
```

|name|description|
|:---|:---|
|Japanese_BIN|Japanese, binary sort|
|Japanese_BIN2|Japanese, binary code point comparison sort|
|Japanese_CI_AI|Japanese, case-insensitive, accent-insensitive, kanatype-insensitive, width-insensitive|
|以下略||

#### データベースの照合順序を取得する

- [sys.databases (TRANSACT-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-2017)

```sql
SELECT
  name
  , collation_name 
FROM
  sys.databases 
WHERE
  name = 'SAMPLE_INSTANCE'; 
```

|name|collation_name|
|:---|:---|
|SAMPLE_INSTANCE|Japanese_CI_AS|

#### サーバーインスタンスのプロパティを取得する

- [SERVERPROPERTY (Transact-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/t-sql/functions/serverproperty-transact-sql?view=sql-server-2017)

```sql
SELECT
  SERVERPROPERTY('InstanceName') AS InstanceName
  , SERVERPROPERTY('MachineName') AS MachineName
  , SERVERPROPERTY('Collation') AS Collation
  , SERVERPROPERTY('CollationID') AS CollationID
  , SERVERPROPERTY('ComparisonStyle') AS ComparisonStyle
  , SERVERPROPERTY('LCID') AS LCID
  , SERVERPROPERTY('SqlCharSet') AS SqlCharSet
  , SERVERPROPERTY('SqlCharSetName') AS SqlCharSetName
  , SERVERPROPERTY('SqlSortOrder') AS SqlSortOrder
  , SERVERPROPERTY('SqlSortOrderName') AS SqlSortOrderName; 
```

|InstanceName|MachineName|Collation|CollationID|ComparisonStyle|LCID|SqlCharSet|SqlCharSetName|SqlSortOrder|SqlSortOrderName|
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
|SAMPLE_INSTANCE|SQLServerが動いているマシン|Japanese_CI_AS|53264|196609|1041|109|cp932|0|bin_ascii_8|

#### 指定データベースのプロパティを取得する

- [DATABASEPROPERTYEX (Transact-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/t-sql/functions/databasepropertyex-transact-sql?view=sql-server-2017)

```sql
SELECT
  DATABASEPROPERTYEX('SAMPLE_INSTANCE', 'Collation') AS Collation
  , DATABASEPROPERTYEX('SAMPLE_INSTANCE', 'ComparisonStyle') AS ComparisonStyle
  , DATABASEPROPERTYEX('SAMPLE_INSTANCE', 'LCID ') AS LCID
  , DATABASEPROPERTYEX('SAMPLE_INSTANCE', 'SQLSortOrder') AS SQLSortOrder; 
```

|Collation|ComparisonStyle|LCID|SQLSortOrder|
|:---|:---|:---|:---|
|Japanese_CI_AS|196609|1041|0|

`Japanese_CI_AS`が規定値みたい。

## 参考

- [Transact-SQL リファレンス (データベース エンジン) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/t-sql/language-reference?view=sql-server-2017)

