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

task :map do
  Dir.glob("#{DST_DIR}/*.txt.gz").each {|path|
    cmd = []
    MINZOOM.upto(MAXZOOM) {|z|
      cmd.push "(gzcat #{path} | Z=#{z} rake _map | sort | uniq)"
    }
    cmd = "(#{cmd.join('; ')})"
    cmd += <<-EOS
 | tippecanoe -f -o mbtiles/#{File.basename(path, '.txt.gz')}.mbtiles \
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
    f = zfxy2geojson(dst_z, dst_f, dst_x, dst_y)
    f[:tippecanoe] = {
      :layer => 'zfxy',
      :minzoom => dst_z - DZ,
      :maxzoom => dst_z - DZ,
    }
    #print "#{[dst_z, dst_f, dst_x, dst_y].join('/')}\n"
    print "\x1e#{JSON.dump(f)}\n"
  end
end

task :style do
  sh <<-EOS
charites build --provider=mapbox style.yml docs/style.json
  EOS
end

task :host do
  sh <<-EOS
budo -d docs
  EOS
end

task :tiles do
  mbtiles = Dir.glob("mbtiles/*.mbtiles").filter {|path|
    not File.exist?("#{path}-journal")
  }
  sh <<-EOS
tile-join -f -e docs/zxy --no-tile-compression \
--no-tile-size-limit \
#{mbtiles.join(' ')}
  EOS
end

