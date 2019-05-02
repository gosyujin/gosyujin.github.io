---
layout: post
title:  実行したSQLで暗黙の型変換が起こっているかどうかはどうやって調べたらよいの(SQL Server)
description: 
category: 
tags: [SQL Server]
---

## あらすじ

- SQL Serverで暗黙の型変換が起こるっていう話と、実際に簡単なSQLを実行して暗黙の型変換(`CONVERT_IMPLICIT`)が発生するのを確認できるという話
    - [SQL Server のチューニングについてまとめてみる - その6 - ( CONVERT_IMPLICIT、暗黙の型変換の怖さを知ろう ) - 都内で働くSEの技術的なひとりごと](http://ryuchan.hatenablog.com/entry/2014/09/07/082145)
    - [SQLServer2005で、暗黙の型変換が行われる](http://blogs.wankuma.com/mrt/archive/2008/03/12/127360.aspx)
- しかし、Java(JDBC)経由で実行されているSQLを再現するにはログ等から情報をかき集めたりする必要があってちょっと手間
    - そもそも欲しいログが出てない事もある…
- SQL Serverの中で実行したSQL持ってないかな？
    - 持ってそう

## 環境

```sql
SELECT SERVERPROPERTY('productversion') as VERSION;
```

|VERSION|
|:---|
|14.0.1000.169|

## 確認方法

システム動的管理ビューから取得できそう。

- [動的管理ビュー (TRANSACT-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views?view=sql-server-2017)

### コマンド

暗黙の型変換が起こっているか確認したいSQLを実行(実際に画面叩くとか)した後に以下のSQLを実行する。

```sql
SELECT
  creation_time
  , last_execution_time
  , execution_count
  , query_plan
  , text 
FROM
  sys.dm_exec_query_stats 
  cross apply sys.dm_exec_query_plan(plan_handle) 
  cross apply sys.dm_exec_sql_text(sql_handle) 
order by
-- これは直前に実行したSQLを見る場合。textをLIKEで絞ったりしてもいいかも
  last_execution_time desc; 
```

### 実行結果

|creation_time|last_execution_time|execution_count|query_plan|text|
|---:|---:|---:|:---|:---|
|2019/04/25 23:18:39.103|2019/04/25 23:22:29.197|17|下記|下記|

#### query_plan

query_planカラムで実行計画を確認できる。

```xml
<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.6" Build="14.0.1000.169">
  <BatchSequence>
    <Batch>
      <Statements>
        <StmtSimple StatementText="(@P0 nvarchar(4000),@P1 nvarchar(4000))UPDATE SAMPLESCHEMA.SAMPLETABLE 
          SET USER_CD = @P0 WHERE SAMPLESCHEMA.SAMPLETABLE.ID = @P1">
(略)
  <!-- この辺で暗黙の型変換が起こっている -->
  <ScalarOperator ScalarString="CONVERT_IMPLICIT(nvarchar(10),[@P0],0)">
    <Convert DataType="nvarchar" Length="20" Style="0" Implicit="1">
      <ScalarOperator>
        <Identifier>
          <ColumnReference Column="@P0"/>
        </Identifier>
      </ScalarOperator>
    </Convert>
  </ScalarOperator>
(略)
```

暗黙の型変換(`CONVERT_IMPLICIT`)が起こっている。

#### text

実行したSQLを探すならtextカラムの方が見やすそう。

```sql
(@P0 nvarchar(4000),@P1 nvarchar(4000))
UPDATE SAMPLESCHEMA.SAMPLETABLE 
SET
  USER_CD = @P0 
WHERE
  SAMPLESCHEMA.SAMPLETABLE.ID = @P1 
```

## 参考

- [CAST および CONVERT (Transact-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/t-sql/functions/cast-and-convert-transact-sql?view=sql-server-2017#implicit-conversions)
- [MasayukiOzawa/SQLServer-Util: SQL Server の各種情報を取得するためのユーティリティ](https://github.com/MasayukiOzawa/SQLServer-Util)
- [SQLServer-JDBC実行計画の取得 | UNITRUST](https://www.unitrust.co.jp/3210)
