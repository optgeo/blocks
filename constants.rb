#TXT_PATH = 'all.txt'
#TXT_PATH = 'fujisan.txt'
TXT_PATH = 'chuseibu.txt'
DST_DIR = 'dst'
DZ = 7
MINZOOM = 12
MAXZOOM = 25
KEI = 8
SRC_EPSG = "EPSG:#{2442 + KEI}"
DST_EPSG = "EPSG:4326"
PORT = 8006
MBTILES_PATH = 'tiles.mbtiles'
URL_PATH = 'blocks'
ZCAT = `uname`.chop == 'Darwin' ? 'gzcat' : 'zcat'
