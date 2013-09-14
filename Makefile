.PHONY: doc

doc:
	@ldoc -d docs src

test:
	@busted
