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
