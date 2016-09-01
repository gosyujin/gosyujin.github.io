---
layout: post
title: "Rubyの変数DATABASE_URLでハマった話"
description: ""
category: 
tags: [Ruby]
---

## あらすじ

- 一台のサーバーに複数のRailsアプリケーションがある
- 新しく一つRailsアプリケーションを作成した
- `config/database.yml` を見るとこんなコメントアウトがあった

```yaml
# On Heroku and other platform providers, you may have a full connection URL
# available as an environment variable. For example:
#
#   DATABASE_URL="mysql2://myuser:mypass@localhost/somedatabase"
#
# You can use this database configuration with:
#
#   production:
#     url: <%= ENV['DATABASE_URL'] %>
#
```

- こんな変数があるのね。 `database.yml` で使ってみた

```yaml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

- 変数を `.bash_profile` あたりに定義

```sh
export DATABASE_URL="mysql2://myuser:mypass@localhost/somedatabase"
```

- 結果、同じサーバーに存在している全部のRailsアプリケーションが上記の接続先を見に行った！

## 原因

コメントでも `DATABASE_URL` を使用してね、とあるが、環境変数に `ENV['DATABASE_URL']` が存在すると `active_record/connection_handling.rb` で `DATABASE_URL` がマージされてしまう模様。

- [Rails アプリケーションを設定する Rails ガイド #データベースを設定する](http://railsguides.jp/configuring.html#%E3%83%87%E3%83%BC%E3%82%BF%E3%83%99%E3%83%BC%E3%82%B9%E3%82%92%E8%A8%AD%E5%AE%9A%E3%81%99%E3%82%8B)

以下、引用。

> config/database.ymlファイルと環境変数ENV['DATABASE_URL']が両方存在する場合、両者の設定はマージして使用されます。以下のいくつかの例を参照して理解を深めてください。
>
> 提供された接続情報が重複している場合、環境変数が優先されます。
>
> 提供された複数の情報が重複しておらず、競合している場合も、常に環境変数の接続設定が優先されます。
>
> poolはENV['DATABASE_URL']で提供される情報に含まれていないので、マージされています。adapterは重複しているので、ENV['DATABASE_URL']の接続情報が優先されています。
>
> ENV['DATABASE_URL']の情報よりもdatabase.ymlの情報を優先する唯一の方法は、database.ymlで"url"サブキーを使用して明示的にURL接続を指定することです。

マージしているのは、このあたりかな。 `./vendor/bundle/ruby/2.1.0/gems/activerecord-4.1.15/lib/active_record/connection_handling.rb`

```rb
66       # Returns fully resolved connection hashes.
67       # Merges connection information from `ENV['DATABASE_URL']` if available.
68       def resolve
69         ConnectionAdapters::ConnectionSpecification::Resolver.new(config).resolve_all
70       end
71
72       private
73         def config
74           @raw_config.dup.tap do |cfg|
75             if url = ENV['DATABASE_URL']
76               cfg[@env] ||= {}
77               cfg[@env]["url"] ||= url
78             end
79           end
80         end
```

まあ影響範囲を考えて使いましょうという話。
