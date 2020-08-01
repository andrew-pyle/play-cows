ELM_MODULE = Cows.elm

all: build

build: $(ELM_MODULE).js

Cows.elm.js: src/$(ELM_MODULE)
	npx elm make src/$(ELM_MODULE) --output=$(ELM_MODULE).js --optimize

.PHONY: clean dev

dev:
	npx elm-live src/$(ELM_MODULE) --open -- --output=$(ELM_MODULE).js --debug

clean:
	rm $(ELM_MODULE).js
