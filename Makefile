planout:
	lua buildresources/pack.lua src/ > dist/planout.lua

install:
	luarocks install penlight
	luarocks install lbc
	luarocks install underscore.lua --from=http://marcusirven.s3.amazonaws.com/rocks/

test:
	cd tests && lua test.lua -v

clean:
	rm -f dist/planout.lua
