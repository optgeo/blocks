require './constants.rb'
require './zfxy.rb'
require 'json'

task :clean do
  sh <<-EOS
rm dst/*
  EOS
end

task :stream do
  sh <<-EOS
pdal translate #{DST_DIR}/#{ENV['FN']}.las STDOUT \
--reader=las \
-f filters.reprojection \
--filters.reprojection.in_srs="#{SRC_EPSG}" \
--filters.reprojection.out_srs="#{DST_EPSG}" \
--writers.text.write_header=false \
--writers.text.precision=9
  EOS
end

desc 'download las file and create zfxy txt at 1m GSD'
task :zfxy do
  File.foreach(TXT_PATH) {|l|
    url = l[0 .. l.rindex('/') - 1]
    fn = l.strip.split('/')[-1].sub('.zip', '')
    next if File.exist?("#{DST_DIR}/#{fn}.txt.gz")
    sh <<-EOS
curl -o #{DST_DIR}/#{fn}.zip #{url}/#{fn}.zip; \
unzip -d #{DST_DIR} #{DST_DIR}/#{fn}.zip; \
FN=#{fn} rake stream | rake _filter | uniq | sort | uniq \
> #{DST_DIR}/#{fn}.txt; \
rm #{DST_DIR}/#{fn}.zip #{DST_DIR}/#{fn}.las; \
gzip -9 #{DST_DIR}/#{fn}.txt
    EOS
  }
end

task :_filter do
  while STDIN.gets
    r = $_.strip.split(',')
    next unless r[4].to_i == 1
    print point2zfxy(25, r[2].to_f, r[0].to_f, r[1].to_f), "\n"
  end
end

def dst_path(path)
  "mbtiles/#{File.basename(path, '.txt.gz')}.mbtiles"
end

desc 'create mbtiles from txt.gz'
task :map do
  Dir.glob("#{DST_DIR}/*.txt.gz").each {|path|
    next if File.exist?(dst_path(path)) && 
      !File.exist?("#{dst_path(path)}-journal")
    cmd = []
    MINZOOM.upto(MAXZOOM) {|z|
      c = <<-EOS
(zcat #{path} | Z=#{z} rake _map | uniq | sort | uniq | \
rake _togeojson)
      EOS
      cmd.push(c.strip)
    }
    cmd = "(#{cmd.join('; ')})"
    cmd += <<-EOS
 | tippecanoe -f -o #{dst_path(path)} \
--minimum-zoom=#{MINZOOM - DZ} --maximum-zoom=#{MAXZOOM - DZ}
    EOS
    sh cmd
  }
end

task :_map do
  dst_z = ENV['Z'].to_i
  while STDIN.gets
    (z, f, x, y) = $_.strip.split('/').map {|v| v.to_i}
    next if f < 0 ##
    dz = z - dst_z
    dst_f = f >> dz
    dst_x = x >> dz 
    dst_y = y >> dz
    print "#{[dst_z, dst_f, dst_x, dst_y].join('/')}\n"
  end
end

task :_togeojson do
  while STDIN.gets
    (z, f, x, y) = $_.strip.split('/').map {|v| v.to_i}
    f = zfxy2geojson(z, f, x, y)
    f[:tippecanoe] = {
      :layer => 'zfxy',
      :minzoom => z - DZ,
      :maxzoom => z - DZ,
    }
    print "\x1e#{JSON.dump(f)}\n"
  end
end

desc 'parallel version of map'
task :parallel_map do
  File.open('filelist.tmp', 'w') {|w|
    Dir.glob('dst/*.txt.gz').each {|path|
      next if File.exist?(dst_path(path))
      w.print path, "\n"
    }
  }
  sh <<-EOS
parallel -j2 SRC_PATH={} rake _parallel_map1 < filelist.tmp; \
rm filelist.tmp
  EOS
end

task :_parallel_map1 do
  sh <<-EOS
parallel -j2 --line-buffer "zcat #{ENV['SRC_PATH']} | \
Z={} rake _map | uniq | sort | uniq | rake _togeojson" \
::: #{(MINZOOM..MAXZOOM).to_a.join(' ')} | \
tippecanoe -f -o #{dst_path(ENV['SRC_PATH'])} \
--minimum-zoom=#{MINZOOM - DZ} --maximum-zoom=#{MAXZOOM - DZ}
  EOS
end


task :style do
  sh <<-EOS
charites build --provider=mapbox style.yml docs/style.json
  EOS
end

task :budo do
  sh <<-EOS
budo -d docs
  EOS
end

desc 'serve the site'
task :host do
  while true
    sh "ruby serve.rb -p #{PORT}"
  end
end

task :restart do
  sh "sudo systemctl stop optgeo.blocks.service"
  sh "sudo systemctl start optgeo.blocks.service"
end

desc 'deply tiles from a bunch of mbtiles'
task :tiles do
  mbtiles = Dir.glob("mbtiles/*.mbtiles").filter {|path|
    not File.exist?("#{path}-journal")
  }
#tile-join -f -e docs/zxy --no-tile-compression \
  sh <<-EOS
tile-join -f -o #{MBTILES_PATH} \
--no-tile-size-limit \
#{mbtiles.join(' ')}
  EOS
end

