.PHONY: doc

doc:
	@ldoc.lua src

test:
	@busted
