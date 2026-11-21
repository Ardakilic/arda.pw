# TinyPNG image compression

How to compress blog images to WebP with the TinyPNG (Tinify) API. Use it only after Arda has confirmed TinyPNG as the compression method (see `AGENTS.md`).

## 1. API key

The key lives outside the repo, in `~/.config/tinify/key` (mode 600). Check that it's there:

```bash
test -s ~/.config/tinify/key && echo present || echo missing
```

If it's missing, stop and ask Arda to create it. He can copy his key from https://tinify.com/dashboard/api (the login link arrives by email). He should run this in his own terminal rather than pasting the key into the chat:

```bash
mkdir -p ~/.config/tinify && printf '%s' 'YOUR_KEY' > ~/.config/tinify/key && chmod 600 ~/.config/tinify/key
```

Never print the key, pass it as a command-line argument, commit it, or put it in a pull request. The commands below feed it to curl as a config file on stdin (`-K -`), so it never shows up in the process list or in any output.

## 2. Compress and convert

Keep originals in a temporary folder outside the repo. Define the helpers once per shell:

```bash
key_cfg() { printf 'user = "api:%s"\n' "$(tr -d '\n\r ' < ~/.config/tinify/key)"; }

# tinify <original> <output.webp> [resize]
# Pass "resize" when the image is larger than 1280 px on either side; it never upscales.
tinify() {
  local loc body='{"convert":{"type":"image/webp"}}'
  [ "$3" = resize ] && body='{"resize":{"method":"fit","width":1280,"height":1280},"convert":{"type":"image/webp"}}'
  loc=$(key_cfg | curl -sS -K - --data-binary @"$1" -D - -o /dev/null https://api.tinify.com/shrink \
    | awk 'tolower($1)=="location:"{print $2}' | tr -d '\r')
  [ -n "$loc" ] || { echo "upload failed for $1: check the key and the file" >&2; return 1; }
  key_cfg | curl -sS -K - -H 'Content-Type: application/json' --data "$body" -D - -o "$2" "$loc" \
    | awk 'tolower($1)=="compression-count:"{print "compressions used this month: " $2}'
}
```

Then, for each image:

```bash
tinify /tmp/originals/bottle.jpg content/posts/<bundle>/images/cover.webp          # already fits in 1280x1280
tinify /tmp/originals/big.jpg    content/posts/<bundle>/images/pour.webp  resize   # larger than 1280 px
```

On macOS, `sips -g pixelWidth -g pixelHeight <file>` shows an image's dimensions.

How it works: `POST /shrink` uploads the image and returns the output URL in the `Location` header. A `POST` to that URL with a JSON body converts the image (and resizes it if asked), then downloads the result.

## 3. Check the result

```bash
file content/posts/<bundle>/images/*.webp   # each must say "Web/P image" and show the expected size
```

If a file isn't a WebP, it contains the API's JSON error (`{"error": ..., "message": ...}`); read the message. A `401 Unauthorized` means the key is wrong. Then open the images and check that they still look right.

## Cost

- Each image costs 2 compressions: 1 for the upload and 1 for the output request, even when that request resizes and converts at once.
- The free plan gives 500 compressions a month, and the helper prints the running count after each image.
- To avoid paying twice for duplicates, upload an image used in several posts only once and copy the resulting `.webp`.
