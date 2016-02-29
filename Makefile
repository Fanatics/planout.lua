planout:
	lua buildresources/pack.lua src/ > dist/planout.lua

install:
	luarocks install penlight

clean:
	rm -f dist/planout.lua
