Arda.pw
--------

This is the codebase of my personal website, [arda.pw](https://arda.pw).

It is powered by [Hugo](https://gohugo.io/).

To run locally, simply execute

```bash
hugo server
```

or if you want to use Docker instead, you can run like

```bash
docker run --rm \
  --name mysite \
  -p 8080:8080 \
  -v ${PWD}:/src \
  -v ${HOME}/hugo_cache:/tmp/hugo_cache \
  hugomods/hugo:exts-non-root \
  server -p 8080
```

To update the theme, simply run

```bash
git submodule update --remote --merge
```

Alternatively, you can use the following make commands:

- `make server` - Start the Hugo development server
- `make docker` - Start the site using Docker
- `make update` - Update the theme submodule
- `make open` - Open the local site in a browser