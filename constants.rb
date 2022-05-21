# G空間情報センターの点群データのURLリストのパス
TXT_PATH = 'fujisan.txt'
# obs: 書き出す MBTiles ファイルのパス（非分割の場合）
MBTILES_PATH = 'tiles.mbtiles'

# txt.gz ファイルを書き出すディレクトリ
DST_DIR = 'dst'
# LAS ごとの MBTiles ファイルを書き出すディレクトリ
MBTILES_DIR = "mbtiles"
# obs: グループごとにまとめた MBTiles を書き出すディレクトリ
GROUPS_DIR = 'groups'
# 一時ファイルのディレクトリ
TMP_DIR = '/tmp'

# ZFXYのzとそれが格納されるタイルのzの差
DZ = 6
# GNU Parallel で並行実行する並行度
J = 3
# 生産するタイルの最小ズーム
MINZOOM = 12
# 生産するタイルの最大ズーム
MAXZOOM = 25
# obs: グループごとに生産する場合のまとめる個数
GROUP_SIZE = 1024

# 静岡点群ファイルの平面直角座標系の系
KEI = 8
# 静岡点群ファイルのEPSGコード
SRC_EPSG = "EPSG:#{2442 + KEI}"
# PDALが書き出すデータのESPGコード
DST_EPSG = "EPSG:4326"

# タイルをホストするポートの番号
PORT = 8006
# URL上のパス
URL_PATH = 'blocks'

# gzip ファイルを展開するコマンドの名前
ZCAT = `uname`.chop == 'Darwin' ? 'gzcat' : 'zcat'

