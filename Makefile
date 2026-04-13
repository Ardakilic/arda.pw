.PHONY: docker server update open

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