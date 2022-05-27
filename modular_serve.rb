require './constants'
require 'sqlite3'
require 'sinatra'

$pool = {}
Dir.glob("#{MODULES_DIR}/*.mbtiles").each {|path|
  $pool[File.basename(path, '.mbtiles')] =
    SQLite3::Database.new(path)
}

def get_tile(z, x, y)
  (z, x, y) = [z, x, y].map{|v| v.to_i}
  key = z < MZ ? '0' : "#{MZ}-#{x >> z - MZ}-#{y >> z - MZ}"
  return 404 unless $pool[key] 
  tile_row = 2 ** z.to_i - y.to_i - 1
  tile = $pool[key].execute <<-EOS
SELECT tile_data FROM tiles WHERE \
zoom_level=#{z} AND tile_column=#{x} AND tile_row=#{tile_row}
  EOS
  tile[0] ? tile[0][0] : 404
end

require './getset.rb'
