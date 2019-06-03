---
layout: post
title: "SQL Serverのカラムに設定されている論理名をまとめて取得する"
description: ""
category: 
tags: [SQL Server, A5 SQL Mk-2]
---

## あらすじ

とあるスキーマの全てのテーブルのカラムに設定されている論理名をSQLでぶっこ抜きたい。

## 環境

```sql
SELECT SERVERPROPERTY('productversion') as VERSION;
```

|VERSION|
|:---|
|14.0.1000.169|

## やり方

カラムの論理名は`sys.extended_properties`の`value`に格納されている。
また、スキーマは`sys.schemas`、テーブルは`sys.tables`、カラムは`sys.columns`にそれぞれ格納されている。

表示したいスキーマとテーブル名あたりで絞って使いたい。

```sql
--A5:SQL Mk-2用の疑似命令
--*SetParameter P0 'SAMPLE_SCHEMA' String
--*SetParameter P1 'SAMPLE_TABLE' String
SELECT
  CONCAT(T1.schema_name, '.', T1.table_name, '.', T1.column_name) AS schema_table_column
  , CONCAT('[', CAST(T2.table_comment AS nvarchar(MAX)), '].[', CAST(T1.column_comment AS nvarchar(MAX)), ']') AS table_comment_column_comment
  , T1.schema_name
  , T1.table_name
  , T1.column_name
  , T2.table_comment
  , T1.column_comment 
FROM
  ( 
    SELECT
      s.name        AS schema_name
      , s.schema_id AS schema_id
      , t.name      AS table_name
      , t.schema_id AS tschema_id
      , c.name      AS column_name
      , e.major_id  AS major_id
      , e.minor_id  AS minor_id
      , e.value     AS column_comment 
    FROM
      sys.schemas s
      , sys.tables t
      , sys.columns c
      , sys.extended_properties e 
    WHERE
      s.schema_id     = t.schema_id 
      AND t.object_id = c.object_id 
      AND c.object_id = e.major_id 
      AND c.column_id = e.minor_id 
      AND s.name      = @P0 
      AND t.name      = @P1
  ) AS T1
  , ( 
    SELECT
      s.name        AS schema_name
      , s.schema_id AS schema_id
      , t.name      AS table_name
      , t.schema_id AS tschema_id
      , e.major_id  AS major_id
      , e.minor_id  AS minor_id
      , e.value     AS table_comment 
    FROM
      sys.schemas s
      , sys.tables t
      , sys.extended_properties e 
    WHERE
      s.schema_id     = t.schema_id 
      AND t.object_id = e.major_id 
      AND e.minor_id  = 0 
-- スキーマとテーブル名で絞る場合はここのコメントアウトを外す
--      AND s.name      = @P0 
--      AND t.name      = @P1
  ) AS T2 
WHERE
  T1.major_id = T2.major_id 
ORDER BY
  T1.major_id, T1.minor_id;
```

#### 実行結果

こんな感じで取得できる。`Schema_Table_Column`と`TableComment_ColumnComment`は個人的に取得しておきたい文字の並び。

|Schema_Table_Column|TableComment_ColumnComment|sname|tname|cname|TableComment|ColumnComment|
|:---|:---|:---|:---|:---|:---|:---|
|SAMPLE_SCHEMA.SAMPLE_TABLE.LOGIN_ID|[ユーザーテーブル].[ログインID]|SAMPLE_SCHEMA|SAMPLE_TABLE|LOGIN_ID|ユーザーテーブル|ログインID|
|SAMPLE_SCHEMA.SAMPLE_TABLE.USER_NAME|[ユーザーテーブル].[ユーザー名]|SAMPLE_SCHEMA|SAMPLE_TABLE|USER_NAME|ユーザーテーブル|ユーザー名|
|SAMPLE_SCHEMA.SAMPLE_TABLE.ADDRESS|[ユーザーテーブル].[住所]|SAMPLE_SCHEMA|SAMPLE_TABLE|ADDRESS|ユーザーテーブル|住所|
|SAMPLE_SCHEMA.SAMPLE_TABLE2.CATEGORY_ID|[カテゴリーテーブル].[カテゴリID]|SAMPLE_SCHEMA|SAMPLE_TABLE2|CATEGORY_ID|カテゴリーテーブル|カテゴリID|
|SAMPLE_SCHEMA.SAMPLE_TABLE2.CATEGORY_NAME|[カテゴリーテーブル].[カテゴリ名]|SAMPLE_SCHEMA|SAMPLE_TABLE2|CATEGORY_NAME|カテゴリーテーブル|カテゴリ名|

## 参考

- [sys.schemas (TRANSACT-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/system-catalog-views/schemas-catalog-views-sys-schemas?view=sql-server-2017)
- [sys.tables (TRANSACT-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/system-catalog-views/sys-tables-transact-sql?view=sql-server-2017)
- [sys.columns (TRANSACT-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/system-catalog-views/sys-columns-transact-sql?view=sql-server-2017)
- [sys.extended_properties (TRANSACT-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/system-catalog-views/extended-properties-catalog-views-sys-extended-properties?view=sql-server-2017) 

