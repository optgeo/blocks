require './constants'
require './zfxy'
require 'fileutils'
require 'zlib'
require 'set'
require 'json'

N = 4

def stream_txt_path
  Dir.glob("#{DST_DIR}/*.txt.gz").shuffle[0..N - 1].each {|path|
    yield path
  }
end

def stream_zfxy
  count = 0
  stream_txt_path {|txt_path|
    count += 1
    $stderr.print "--- processing #{txt_path} ##{count} of #{N}\n"
    Zlib::GzipReader.open(txt_path) {|gz|
      set = Set.new
      gz.each_line {|l|
        (z, f, x, y) = l.strip.split('/').map {|v| v.to_i}
        MAXZOOM.downto(MINZOOM) {|dst_z|
          dz = z - dst_z
          set << [
            dst_z,
            f >> dz,
            x >> dz,
            y >> dz
          ]
        }
      }
      set.each {|v|
        yield v
      }
    }
  }
end

def tippecanoe(key)
  fifo_path = "#{MODULES_DIR}/#{key}.fifo"
  mbtiles_path = "#{MODULES_DIR}/#{key}.mbtiles"
  FileUtils.rm(fifo_path) if File.exist?(fifo_path)
  File.mkfifo(fifo_path)
  cmd = <<-EOS
tippecanoe --force \
--minimum-zoom=#{MINZOOM - DZ} --maximum-zoom=#{MAXZOOM - DZ} \
--no-tile-size-limit \
--layer=default \
-o #{mbtiles_path}  #{fifo_path}
  EOS
  spawn cmd
  $stderr.print "\t created #{fifo_path}\n"
  File.open(fifo_path, 'w')
end

def close_fifos
  $fifos.each {|k, v|
    v.close 
    Process.wait
    FileUtils.rm("#{MODULES_DIR}/#{k}.fifo")
  }
end

def dst_fifo_key(z, f, x, y)
  dst_z = z - DZ
  if dst_z < MZ
    '0'
  else
    dz = z - MZ
    "#{MZ}-#{x >> dz}-#{y >> dz}"
  end
end

def get_fifo(z, f, x, y)
  fifo_key = dst_fifo_key(z, f, x, y)
  if $fifos.has_key?(fifo_key)
    $fifos[fifo_key]
  else
    $fifos[fifo_key] = tippecanoe(fifo_key)
  end
end

$fifos = {
  '0' => tippecanoe('0')
}

def push(z, f, x, y)
  fifo = get_fifo(z, f, x, y)
  f = zfxy2geojson(z, f, x, y)
  f[:tippecanoe] = {
    :layer => 'zfxy',
    :minzoom => z - DZ,
    :maxzoom => z - DZ
  }
  fifo.print "\x1e#{JSON.dump(f)}\n"
  #print "#{[z, f, x, y]} -> #{z - DZ} #{dst_fifo_key(z, f, x, y)}\n"
end

def main
  stream_zfxy {|z, f, x, y|
    push(z, f, x, y)
  }
  close_fifos
end

main

