ELM_MODULE = Cows.elm

all: $(ELM_MODULE).js

Cows.elm.js: src/$(ELM_MODULE)
	elm make src/$(ELM_MODULE) --output=$(ELM_MODULE).js --optimize

.PHONY: build clean run

run:
	elm reactor

clean:
	rm $(ELM_MODULE).js
