# Production Dependencies  = elm
# Development Dependencies = elm, elm-live
ELM_MODULE = Cows.elm

all: build

Cows.elm.js: src/$(ELM_MODULE)
	elm make src/$(ELM_MODULE) --output=$(ELM_MODULE).js --optimize

.PHONY: build clean dev

dev:
	elm-live src/$(ELM_MODULE) --open -- --output=$(ELM_MODULE).js --debug

build: $(ELM_MODULE).js

clean:
	rm $(ELM_MODULE).js
