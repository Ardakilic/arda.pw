.PHONY: help docker server update open

help:
	@echo "Available commands:"
	@echo "  make server - Start the Hugo development server"
	@echo "  make docker - Start the site using Docker"
	@echo "  make update - Update the theme submodule"
	@echo "  make open   - Open the local site in a browser"

server:
	hugo server

docker:
	docker run --rm \
	  --name mysite \
	  -p 8080:8080 \
	  -v ${PWD}:/src \
	  -v ${HOME}/hugo_cache:/tmp/hugo_cache \
	  hugomods/hugo:exts-non-root \
	  server -p 8080

update:
	git submodule update --remote --merge

open:
	open http://localhost:8080