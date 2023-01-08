CC=/usr/bin/nim

all: article.nim master.nim render.nim
	$(CC) c master.nim
	$(CC) c render.nim
	$(CC) c article.nim

article: article.nim
	$(CC) c article.nim

render: render.nim
	$(CC) c render.nim

master: master.nim
	$(CC) c master.nim