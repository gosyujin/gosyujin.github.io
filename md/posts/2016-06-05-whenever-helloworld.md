---
layout: post
title: "Rubyで自然言語っぽくcrontab管理できるwheneverを使う"
description: ""
category: 
tags: [Ruby]
---

## あらすじ

- cronタスクを書きたいけど、そのままctontabを書きかえたりするのはめんどいし怖い( `crontab -r` とか)
- Rubyでcrontab管理をできるライブラリwheneverを使う

[javan/whenever: Cron jobs in Ruby](https://github.com/javan/whenever)

> Whenever is a Ruby gem that provides a clear syntax for writing and deploying cron jobs.

## 参考

- [Wheneverは導入が超簡単なcrontab管理ライブラリGemです！[Rails4.2 x Ruby2.3] - 酒と泪とRubyとRailsと](http://morizyun.github.io/blog/whenever-gem-rails-ruby-capistrano/)
- [Railsで定期的にバッチ回す「Whenever」 - Qiita](http://qiita.com/yumiyon/items/388fbb84450f49a6ab0d)

## 環境

- Ruby 2.3.0
- Rails 4.1.6

## 手順

- `Gemfile` に以下を追記し、 `bundle install`

```ruby
gem 'whenever', require: false
```

- `bundle exec wheneverrize .` でスケジュール記述するファイルを作成する

```sh
$ bundle exec wheneverize .
[add] writing `./config/schedule.rb'
[done] wheneverized!
```

- `config/schedule.rb` の記述はこんな感じで記述できる
  - `every n hour` など自然言語っぽく書けてわかりやすい

```ruby
# ログ出力先
set :output, "log/cron.log"
# productionの場合はproductionに
set :environment, "development"

# 3時間毎、他にも色々書き方ある(公式のREADME参照)
every 3.hours do
  # Rails内のメソッド実行するときはrunner
  runner "MyModel.some_process"
  # rakeタスクの場合はrake
  rake "my:rake:task"
  # コマンド自体も記述できる
  command "/usr/bin/my_great_command"
end

# いわゆるcronの書式でも書ける
every '0 0 27-31 * *' do
  command "echo 'hello'"
end
```

### crontab更新と削除

```sh
$ bundle exec whenever --clear-crontab
[write] crontab file 
```

```sh
$ bundle exec whenever --update-crontab
[write] crontab file updated
```

### スケジュール確認

- `bundle exec whenever` で確認

```
$ bundle exec whenever
* * * * * /bin/bash -l -c 'cd /Users/kk_Ataka/github/sample_whenever 実行するタスク'

## [message] Above is your schedule file converted to cron syntax; your crontab file was not updated.
## [message] Run `whenever --help' for more options.
```

- `crontab -l` でも反映されている事確認できる

```
# Begin Whenever generated tasks for: /Users/kk_Ataka/github/sample_whenever/config/schedule.rb
0 * * * * config/schedule.rbに定義したcron

# End Whenever generated tasks for: /Users/kk_Ataka/github/sample_whenever/config/schedule.rb
```

- 同じサーバー内の複数のプロジェクトで `whenever --update-crontab` , `whenever --clear-crontab` を実行しても、そのプロジェクトに紐づくcronのみ削除されるので安心
