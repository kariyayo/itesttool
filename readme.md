# itesttool
WebアプリケーションのEnd-to-Endのテストを自動化するためのツール。  
RSpecにユーティリティを追加して実現してます。

## GET リクエストを送信する
GET リクエスト送って、レスポンスコードを確認するには以下のようにします。  
`_given` ブロックでテストの前提条件を書きます。`_given`は、単純にRSpecの`before`の別名です。  
`_when` ブロックでGETリクエストを送ります。  
`_then` ブロック内でres変数を使うことでレスポンスにアクセスできます。  
resは、Net::HTTPResponseオブジェクトです。

    describe 'send GET request' do
      _given {
        # 前提条件を書く
      }
      _when { get 'http://localhost:4567/index' }
      _then {
        res.code.should eq '200'
      }
    end

## レスポンスを検証する
上の例にもありますが、ステータスコードは`res.code.should eq '200'`と書きます。  
レスポンスボディは`res.body.should eq 'Hello world!'`というように書きます。

レスポンスボディが、JSON、XML、HTMLの場合はそれぞれ、JSONPath、XPath、CSSセレクタを用いて要素を検証できます。  
JSONPath、XPathについては、下のサイトを参考にしてください。  
[http://goessner.net/articles/JsonPath/](http://goessner.net/articles/JsonPath/)

また、配列に対する検証のために、以下のカスタムマッチャーを定義してます。  

  - `all_be_type_of`
  - `all_be_gt`
  - `all_be_gt_eq`
  - `all_be_lt`
  - `all_be_lt_eq`
  - `be_sorted`


### JSON
JSONPathを用いて、以下のように検証できます。  

    res['$.team'].should eq ['ABC']
    res['$.members..name'].should eq ['Ichiro', 'Jiro', 'Saburo']
    res['$.members..age'].should include 32
    res['$.members[::]'].should have(3).items
    res['$.members[::]'].should have_at_most(3).items
    res['$.members[::]'].should have_at_least(1).items
    res['$.members..name'].should all_be_type_of :string
    res['$.members..age'].should all_be_type_of :integer
    res['$.members..age'].should all_be_gt 11
    res['$.members..age'].should all_be_gt_eq 12
    res['$.members..age'].should all_be_lt 33
    res['$.members..age'].should all_be_lt_eq 32
    res['$.members..age'].should be_sorted :desc


同じ要素は以下のようにした方が見やすいかも。

    member_ages = res['$.members..age']
      member_ages.should all_be_type_of :integer
      member_ages.should all_be_gt 11
      member_ages.should all_be_gt_eq 12
      member_ages.should all_be_lt 33
      member_ages.should all_be_lt_eq 32
      member_ages.should be_sorted :desc

また、JSON schemaによる検証もできます。  
json_schema/hello.js ファイルに以下のようなJSON schemaが記述します。

    {
      "type": "object",
      "properties": {
        "team": {"type": "string", "required": true},
        "members": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": {"type": "string", "required": true},
              "age":  {"type": "integer", "required": true}
            }
          }
        }
      }
    }

`_then`ブロックに以下のように記述することで、レスポンスボディが上記のJSON schemaとマッチするかを検証できます。

    res.body.should eq_schema_of 'json_schema/hello.json'


### XML
XPathを用いて以下のように検証できます。

    res['/root/team/text()'].should eq ['ABC']
    res['/root/members//name/text()'].should eq ['Ichiro', 'Jiro', 'Saburo']
    res['/root/members//age/text()'].should include '32'
    res['/root/members/*'].should have(3).items
    res['/root/members/*'].should have_at_most(3).items
    res['/root/members/*'].should have_at_least(1).items
    res['/root/members//age/text()'].should all_be_gt 11
    member_ages = res['/root/members//age/text()']
      member_ages.should all_be_gt_eq 10
      member_ages.should all_be_lt 33
      member_ages.should all_be_lt_eq 32
      member_ages.should be_sorted :desc
    res['/root/members/member/@order'].should be_sorted :asc


### HTML
CSSセレクタを用いて以下のように検証できます。

    res['title'].should eq ['Page Title!']
    res['h1#team'].should eq ['ABC']
    res['.member dd.name'].should eq ['Ichiro', 'Jiro', 'Saburo']
    res['.member dd.age'].should include '32'
    res['.member'].should have(3).items
    res['.member'].should have_at_most(3).items
    res['.member'].should have_at_least(1).items
    res['.member dd.age'].should all_be_gt 11
    member_ages = res['.member dd.age']
      member_ages.should all_be_gt_eq 10
      member_ages.should all_be_lt 33
      member_ages.should all_be_lt_eq 32
      member_ages.should be_sorted :desc


## リクエストヘッダを設定する
リクエストヘッダの設定の仕方は、2通りあります。  
1つ目が、`get`の第３引数としてハッシュを渡す方法です。

    _when {
      get 'http://localhost:4567/index.html', as_html,
            'referer' => 'http://local.example.com',
            'user_agent' => 'itesttool'
    }
    _then {
      res.code.should eq '200'
    }

2つ目が、`_given`ブロックで`heades`を使う方法です。

    _given {
      headers 'referer' => 'http://local.example.com',
              'user_agent' => 'itesttool'
    }
    _when { get 'http://localhost:4567/index.html', as_html }
    _then {
      res.code.should eq '200'
    }


## POSTリクエストを送信する
POSTリクエストを送信する場合、`get`の代わりに`post`を使います。  
第1引数に送信先URL、第2引数にリクエストボディ、第３引数にレスポンスのフォーマット、を指定します。

### formデータ
リクエストボディに、formデータを設定する場合は、`body_as_form`を使用します。

    _when {
      post 'http://localhost:4567/login',
           body_as_form('nickname' => 'admin',
                        'password' => 'pass'),
           res_is_json
    }
    _then {
      res.code.should eq '200'
      res['$.nickname'].should eq ['admin']
    }

### JSON
リクエストボディに、JSONを設定する場合は、`body_as_json`を使用します。

    _when {
      post 'http://localhost:4567/echo',
           body_as_json('name' => 'Shiro',
                        'age' => 2),
           res_is_json
    }
    _then {
      res.code.should eq '200'
      res.body.should eq '{"name":"Shiro","age":2}'
    }

単純に、`body`を使って直接文字列で設定することもできます。

    _when {
      post 'http://localhost:4567/echo',
           body第３('{"name":"Shiro","age":2}'),
           res_is_json
    }
    _then {
      res.code.should eq '200'
      res.body.should eq '{"name":"Shiro","age":2}'
    }

## PUT, DELETEリクエスト
PUT, DELETEリクエストの場合は、`post`の代わりに`put`,`delete`を使ってください。  
後は`post`の場合といっしょです。

## ステータスコードのみのテスト
とりあえずGETリクエスト送って、ステータスコードだけ確認したい、みたいなときは以下のように書けます。  
`status_check`の引数に、URLの配列を指定してください。

    describe 'Status 200 check' do
      status_check [
          'http://localhost:4567/index.json',
          'http://localhost:4567/index.xml',
          'http://localhost:4567/index.html',
          'http://localhost:4567/index'
      ]
    end

