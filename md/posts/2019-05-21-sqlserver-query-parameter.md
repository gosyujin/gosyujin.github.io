---
layout: post
title: SQL Serverの動的管理ビューから、実行したSQL(とバインド変数)を取得する
description: 
category: 
tags: [SQL Server, xQuery]
---

## あらすじ

[前回の記事](https://gosyujin.github.io/2019/05/02/sqlserver-convert-implicit/)では暗黙の型変換が起こっているか調べるために動的管理ビューから実行計画(`query_plan`)とSQL(`text`)を取得した。
実行計画にはいろいろ情報が入っていてバインド変数のパラメータも埋めこまれている。

組み合わせたら、実行したSQL(とバインド変数)がわかるのでは。

## 前提条件

そもそも、いい感じのフレームワークとかロガーを導入しており、実行したSQLのログが出てればそれで確認すれば良いので◎

色々調べるのがつらい環境だとこの方法で確認してみる価値があるかも。

- ログにSQL文が出力されない
- ライブラリ(変数バインド済のSQLを吐いてくれるP6Spyなど)が入れづらい
    - 外界と遮断されているとか
- ローカル環境、あるいはそれなりに小規模な環境
    - 頻繁にみんながアクセスする環境だと、動的管理ビューから情報が流れていく

## 環境

```sql
SELECT SERVERPROPERTY('productversion') as VERSION;
```

|VERSION|
|:---|
|14.0.1000.169|

## 手順

### おさらい

```sql
SELECT
  query_plan
  , text 
FROM
  sys.dm_exec_query_stats 
  cross apply sys.dm_exec_query_plan(plan_handle) 
  cross apply sys.dm_exec_sql_text(sql_handle) 
ORDER BY
  last_execution_time DESC; 
```

これで実行計画(`query_plan`)とSQL(`text`)を取得できた。

### query_planからパラメータ取得

#### 仕様

`query_plan`の仕様は[Showplan Schema](http://schemas.microsoft.com/sqlserver/2004/07/showplan/)の[ここ](http://schemas.microsoft.com/sqlserver/2004/07/showplan/sql2017/showplanxml.xsd)に定義されている。

#### ほしいパス

バインド変数とパラメータは`けっこう深い階層/ParameterList/ColumnReference`にセットされている。

```xml
(略)
<ParameterList>
  <ColumnReference Column="@P0"
  ParameterDataType="nvarchar(4000)"
  ParameterCompiledValue="N'TEST'" />
...
</ParameterList>
(略)
```

仕様を見ながら定義を上へ上へさかのぼっていくと、`ParameterList`が格納される可能性があるパスはこの3つっぽい。

1. `/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/ParameterList`
1. `/ShowPlanXML/BatchSequence/Batch/Statements/StmtCond/Condition/QueryPlan/ParameterList`
1. `/ShowPlanXML/BatchSequence/Batch/Statements/StmtCursor/CursorPlan/Operation/QueryPlan/ParameterList`

#### 実際に取得

引っこ抜いた。(とりあえず1.の`～/StmtSimple/～`だけ)

```sql
WITH XMLNAMESPACES( 
  DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
) 
SELECT
  -- 2. ParameterList/ColumnReferenceをパラメータ引数の分forで回す
  item.query( 
    '
        <parameters>
          {
            for $i in ColumnReference
              return <parameter>{string($i/@Column)},{string($i/@ParameterCompiledValue)}</parameter>
          }
        </parameters>
      '
  ) AS param
  , text 
FROM
  sys.dm_exec_query_stats 
  CROSS APPLY sys.dm_exec_query_plan(plan_handle) 
  CROSS APPLY sys.dm_exec_sql_text(sql_handle)
  -- 1. query_planからParameterListタグ下を取得
  OUTER APPLY query_plan.nodes( 
    '/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/ParameterList'
  ) AS T(item) 
ORDER BY
  last_execution_time DESC;
```

### 実行結果

|param|text|
|:---|:---|
|下記|下記|

この二つから実行したSQLがわかる！

#### param

うまくパラメータだけ取得できた。

```xml
<p1:parameters xmlns:p1="http://schemas.microsoft.com/sqlserver/2004/07/showplan">
  <p1:parameter>@P1,N'SAMPLE_PARAM2'</p1:parameter>
  <p1:parameter>@P0,N'SAMPLE_PARAM'</p1:parameter>
</p1:parameters>
```

#### text

こっちは特に変わらず。

```sql
(@P0 nvarchar(4000),@P1 nvarchar(4000))
SELECT
  *
FROM
  SAMPLESCHEMA.SAMPLETABLE 
WHERE
  testcol1 = @P0
AND
  testcol2 = @P1
```

### FETCH API_CURSOR

途中で出てくる`FETCH API_CURSOR...`ってやつについて。

```xml
<ShowPlanXML
xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan"
Version="1.6" Build="14.0.1000.169">
<BatchSequence>
  <Batch>
    <Statements>
      <StmtCursor
        StatementText="FETCH API_CURSOR000000000000XXXX" StatementId="1"
        StatementCompId="1" StatementType="FETCH CURSOR"
        RetrievedFromCache="true">
        <CursorPlan CursorName="API_CURSOR000000000000XXXX" />
      </StmtCursor>
    </Statements>
  </Batch>
  </BatchSequence>
</ShowPlanXML>
```

```sql
FETCH API_CURSOR000000000000XXXX
```

ちょっと邪魔…。

- [execution plan - Lots of "FETCH API_CURSOR0000..." on sp_WhoIsActive ( SQL Server 2008 R2 ) - Database Administrators Stack Exchange](https://dba.stackexchange.com/questions/110784/lots-of-fetch-api-cursor0000-on-sp-whoisactive-sql-server-2008-r2)

## 参考

- [FLWOR ステートメントと繰り返し (XQuery) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/xquery/flwor-statement-and-iteration-xquery?view=sql-server-2017)
- [string 関数 (XQuery) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/xquery/data-accessor-functions-string-xquery?view=sql-server-2017)
- [FROM (Transact-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/ja-jp/sql/t-sql/queries/from-transact-sql?view=sql-server-2017)

> CROSS または OUTER は、APPLY を使用して指定する必要があります。 CROSS を指定した場合は、left_table_source の指定行に対して right_table_source を評価し、空の結果セットが返されると、行は生成されません。
>
> OUTER を指定した場合は、left_table_source の各行に対して right_table_source を評価し、空の結果セットが返されても、各行に対して 1 行が生成されます。

