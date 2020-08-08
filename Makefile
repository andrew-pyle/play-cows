APP_NAME = Play-Cows
APP_VERSION = 0.2.0
ELM_MODULE = Cows.elm

all: build

build: $(ELM_MODULE).js service-worker.js

Cows.elm.js: src/$(ELM_MODULE)
	npx elm make src/$(ELM_MODULE) --output=$(ELM_MODULE).js --optimize

.PHONY: clean dev dev-sw service-worker.js

# Write version numbers via this Makefile
service-worker.js:
	sed -i 's|^const APP_VERSION =.*;|const APP_VERSION = "$(APP_VERSION)";|' service-worker.js
	sed -i 's|^const APP_NAME =.*;|const APP_NAME = "$(APP_NAME)";|' service-worker.js
	sed -i 's|^const ELM_MODULE =.*;|const ELM_MODULE = "$(ELM_MODULE).js";|' service-worker.js

dev:
	npx elm-live src/$(ELM_MODULE) --open -- --output=$(ELM_MODULE).js --debug

dev-sw:
	npx elm-live src/$(ELM_MODULE) --open --no-reload -- --output=$(ELM_MODULE).js

clean:
	rm $(ELM_MODULE).js
