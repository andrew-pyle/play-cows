ELM_MODULE = Cows.elm

all: build

Cows.elm.js: src/$(ELM_MODULE)
	elm make src/$(ELM_MODULE) --output=$(ELM_MODULE).js --optimize

.PHONY: build clean run

run:
	elm reactor

build: $(ELM_MODULE).js

clean:
	rm $(ELM_MODULE).js
