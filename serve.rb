require './constants'
require 'sqlite3'
require 'sinatra'

DB = SQLite3::Database.new(MBTILES_PATH)

def get_tile(z, x, y)
  tile_row = 2 ** z.to_i - y.to_i - 1
  tile = DB.execute <<-EOS
SELECT tile_data FROM tiles WHERE \
zoom_level=#{z} AND tile_column=#{x} AND tile_row=#{tile_row}
  EOS
  tile[0] ? tile[0][0] : 404
end

set :protection, :except => [:json_csrf]

get '/blocks' do
  redirect '/blocks/'
end

get '/blocks/index.html' do
  redirect '/blocks/'
end

get '/blocks/' do
  content_type 'text/html'
  File.read('docs/index.html')
end

get '/blocks/module.js' do
  content_type 'text/javascript'
  File.read('docs/module.js')
end

get '/blocks/style.css' do
  content_type 'text/css'
  File.read('docs/style.css')
end

get '/blocks/style.json' do
  content_type 'application/json'
  File.read('docs/style.json')
end

get '/blocks/zxy/:z/:x/:y.pbf' do |z, x, y|
  content_type 'application/vnd.mapbox-vector-tile'
  response.headers['Content-Encoding'] = 'gzip'
  get_tile(z, x, y)
end
