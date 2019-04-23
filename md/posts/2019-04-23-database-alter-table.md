---
layout: post
title: 色々なDBのバージョン確認方法とか論理名のつけ方とか
description: 
category: 
tags: [Oracle, SQL Server, PostgreSQL, DB2]
---

## あらすじ

二つ以上のDBで同じことをやろうとすると混乱するのでメモ。

とりあえずとっかかりだけ。ここを見て思い出していく。

※ 全部SQLべた書きで何とかする方針

- バージョン確認
    - いろんな方法があるけど、GUI(xxAdminみたいな)からSQLを実行して確認する方法
- バックアップ
    - 厳密じゃなくていい。SELECTで取得したデータを新しいテーブルに流し込むだけ
- カラム増やす
- 論理名つける
- テーブル削除

## Oracle(12.1.0.2.0)

### バージョン確認

```sql
select * from v$version;
```

|BANNER|CON_ID|
|:---|:---|
|Oracle Database 12c Standard Edition Release 12.1.0.2.0 - 64bit Production|0|
|PL/SQL Release 12.1.0.2.0 - Production|0|
|CORE	12.1.0.2.0	Production|0|
|TNS for 64-bit Windows: Version 12.1.0.2.0 - Production|0|
|NLSRTL Version 12.1.0.2.0 - Production|0|

### バックアップ

```sql
CREATE TABLE 
  バックアップ先のスキーマ名.テーブル名
AS SELECT * FROM 
  バックアップ元のスキーマ名.テーブル名;
```

### カラム増やす

```sql
ALTER TABLE 
  スキーマ名.テーブル名
ADD ( 
   testcol1 VARCHAR2(11)
  ,testcol2 TIMESTAMP(3)
);
```

### 論理名つける

```sql
COMMENT ON COLUMN 
  スキーマ名.テーブル名.testcol1
IS 
  'コメント';
```

### テーブル削除

```sql
DROP TABLE 
  スキーマ名.テーブル名;
```

## SQL Server(14.0.1000.169)

個人的にSQL Serverは癖があるように感じる…。

### バージョン確認

```sql
SELECT SERVERPROPERTY('productversion') as VERSION;
```

|VERSION|
|:---|
|14.0.1000.169|

### バックアップ

```sql
SELECT * INTO 
  バックアップ先のスキーマ名.テーブル名
FROM 
  バックアップ元のスキーマ名.テーブル名;
```

### カラム増やす

```sql
ALTER TABLE 
  スキーマ名.テーブル名
ADD 
   testcol1 NVARCHAR(11)
  ,testcol2 DATETIME2;
```

### 論理名つける

これが思い出せない。

```sql
EXEC sys.sp_addextendedproperty
  @name=N'MS_Description'
 ,@value=N'コメント'
 ,@level0type=N'SCHEMA'
 ,@level0name=N'スキーマ名'
 ,@level1type=N'TABLE'
 ,@level1name=N'テーブル名'
 ,@level2type=N'COLUMN'
 ,@level2name=N'testcol1'
```

### テーブル削除

```sql
DROP TABLE 
  スキーマ名.テーブル名;

```

## DB2(v11.1.3030.239)

### バージョン確認

```sql
SELECT SERVICE_LEVEL FROM SYSIBMADM.ENV_INST_INFO;
```

|SERVICE_LEVEL|
|:---|
|DB2 v11.1.3030.239|

### バックアップ

```sql
CREATE TABLE
  バックアップ先のスキーマ名.テーブル名
AS (
  SELECT * FROM
    バックアップ元のスキーマ名.テーブル名
) WITH DATA; 
```

### カラム増やす

```sql
ALTER TABLE
  スキーマ名.テーブル名
ADD 
  testcol1 VARCHAR (1);
```

### 論理名つける

```sql
COMMENT ON COLUMN
  スキーマ名.テーブル名.カラム名
IS
  'コメント'; 
```

### テーブル削除

```sql
DROP TABLE
  スキーマ名.テーブル名;
```

## PostgreSQL(11.2)

### バージョン確認

```sql
SELECT VERSION();
```

|version|
|:---|
|PostgreSQL 11.2, compiled by Visual C++ build 1914, 64-bit|

### バックアップ

```sql
CREATE TABLE 
  バックアップ先のスキーマ名.テーブル名
AS SELECT * FROM 
  バックアップ元のスキーマ名.テーブル名;
```

### カラム増やす

```sql
ALTER TABLE 
  スキーマ名.テーブル名
ADD 
  testcol1 VARCHAR(3),
ADD 
  testcol2 VARCHAR(5);
```
### 論理名つける

```sql
COMMENT ON COLUMN 
  スキーマ名.テーブル名.testcol1
IS
  'コメント';
```

### テーブル削除

```sql
DROP TABLE 
  スキーマ名.テーブル名;
```

