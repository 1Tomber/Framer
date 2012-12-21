all: build

build:
	make clean
	mkdir -p build
	./node_modules/browserify/bin/cmd.js src/init.coffee -o build/framer.js
	cp build/framer.js template/framer.js

clean:
	rm -rf dist

.PHONY: build clean