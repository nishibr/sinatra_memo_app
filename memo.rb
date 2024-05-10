# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

DB_JSON_PATH = 'db/db.json'

# エスケープ処理
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

# メモ読み込み
def read_memos
  if File.exist?(DB_JSON_PATH)
    JSON.parse(File.read(DB_JSON_PATH))
  else
    []
  end
end

# メモ書き込み
def write_memos(memos)
  File.open(DB_JSON_PATH, 'w') { |f| JSON.dump(memos, f) }
end

# 存在しないURLにアクセスした際の処理
not_found do
  @title = '404 Not Found'
  erb :not_found
end

# メモ一覧表示へリダイレクト
get '/' do
  redirect to('/memos')
end

# メモ一覧表示
get '/memos' do
  @title = 'top'
  @memos = read_memos
  erb :index
end

# メモの作成画面表示
get '/memos/new' do
  @title = 'new'
  erb :new
end

# メモの詳細表示
get '/memos/:id' do |id|
  @title = 'show'
  @memo = read_memos['memos'].find { |memo| memo['id'] == id }
  erb :show
end

# メモの作成
post '/memos' do
  memos = read_memos
  id = ((read_memos['memos'].map { |memo| memo['id'].to_i }.max || 0) + 1).to_s
  new_memo = { 'id' => id, 'title' => params[:title], 'content' => params[:content] }
  memos['memos'] << new_memo
  write_memos(memos)
  redirect '/memos'
end

# メモの編集画面表示
get '/memos/:id/edit' do |id|
  @title = 'edit'
  @memo = read_memos['memos'].find { |memo| memo['id'] == id }
  erb :edit
end

# メモの編集
patch '/memos/:id/edit' do |id|
  memos = read_memos
  memos['memos'].each do |memo|
    if memo['id'] == id
      memo['title'] = params[:title]
      memo['content'] = params[:content]
    end
  end
  write_memos(memos)
  redirect '/memos'
end

# メモの削除
delete '/memos/:id' do |id|
  memos = read_memos
  memos['memos'].reject! { |memo| memo['id'] == id }
  write_memos(memos)
  redirect '/memos'
end
