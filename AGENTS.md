# AGENTS.md

Guidance for AI agents working on [arda.pw](https://arda.pw), Arda Kılıçdağı's personal blog: a Hugo site using the `hugo-coder` theme (a git submodule in `themes/`).

## Repository basics

- Posts are leaf page bundles: `content/posts/YYYY-MM-DD-<slug>/index.md` with the post's images in `images/` next to it.
- Front matter is YAML. Taxonomies are `categories` and `tags`, and `slug` sets the URL (`/posts/<slug>/`).
- Preview: `make docker`, then open http://localhost:8080. It hides drafts; to see them, run the Docker command from the `Makefile` with `-D` added. `make server` / `hugo` need Dart Sass installed locally. `hugo list all` checks that the content parses without rendering the site.
- Hugo skips posts dated in the future, so never set a `date` later than now.
- Deploys: GitHub Actions publishes the site on every push to `master`. Never push to `master`. Pull `master`, branch off it, commit, and open a pull request for Arda to review.
- Commits use conventional prefixes, for example `feat: add <drink> tasting notes`.

## Drink posts (whisky and other drinks)

Drink posts are Arda's own tasting notes. Every new one must look and read like the existing ones in `content/posts/*-tasting-notes/`. Read two or three of them before writing a new one.

### Source, voice and honesty

- Arda usually writes his notes in Turkish, often in a Telegram drinking group. Translate them into English, in the first person, keeping his wording, humour, emoji, `:D` and his `?` hedges ("green apple?"). Don't turn it into marketing copy.
- **Never invent anything**: no tasting notes, prices, dates, purchase stories or opinions he didn't give. If a section has no source, say so ("I didn't write any down for this one") or leave it out.
- A bottle without real tasting notes becomes `draft: true` with the title `<Name>: Short Notes`. Don't publish it.
- Facts about the bottle (distillery, region, ABV, casks, size) come from the label or box, or from a reliable source. Keep it to a couple of sentences. If the label contradicts his notes (for example the ABV), use the label and say so in the pull request.
- If one of his sentences is cut off or unclear, keep only what's certain and flag it in the pull request.
- Privacy: never name the group or other members. Refer to them as "a friend".

### Bundle and front matter

- Folder: `content/posts/YYYY-MM-DD-<name>-tasting-notes/`. The date is when Arda wrote the note, not when he bought the bottle. The slug is the folder name without the date.
- Title: `<Drink name>: Tasting Notes`. Description: one sentence summing up the notes, at most about 160 characters.

```yaml
---
title: "Ardmore Legacy: Tasting Notes"
slug: "ardmore-legacy-tasting-notes"
date: "2026-11-22T01:00:00+03:00"
description: "One sentence on the drink and its main notes."
featuredImage: "posts/ardmore-legacy-tasting-notes/images/cover.webp"
tags:
  - whisky
  - single-malt
  - scotch
  - highland
  - peated
  - ardmore
  - tasting-notes
  - english
categories:
  - Drinks
author: "Arda Kılıçdağı"
draft: false
---
```

### Category and tags

- The category is always `Drinks`.
- Tags are lowercase kebab-case. Reuse existing tags rather than inventing synonyms. List what's in use with:
  `awk '/^tags:/{f=1;next} /^[a-z]+:/{f=0} f&&/^  - /{print $2}' content/posts/*-tasting-notes/index.md | sort | uniq -c | sort -rn`
- Every post: the drink-type tag (`whisky` for every whisky or whiskey, Irish included) and `english`. Add `tasting-notes` when the post has real notes.
- Then, where they apply:
  - type: `single-malt`, `blended`, `blended-malt`
  - origin: `scotch`, `irish`, `welsh`, `swedish`, …
  - Scotch region: `speyside`, `islay`, `highland`, `lowland`
  - character: `peated`, `sherry-cask`, `bourbon-cask`
  - context: `travel-retail`, `sample`, `cocktail`
  - brand or distillery: `talisker`, `glenlivet`, `ardmore`, …
- For drinks other than whisky, keep the same rules but swap the `whisky` tag for the drink type (`gin`, `rum`, `beer`, `wine`, `liqueur`, …). Adapt the table rows to the drink, for example **Brewery** and **Style** for beer.

### Body structure

1. **Intro**: first person. How and where he got the bottle, plus a couple of sentences about the drink itself.
2. Inline photos where they help.
3. `## At a Glance`: a two-column table with an empty header row (`| | |` then `|---|---|`). Rows in this order: **Whisky** (or the drink type), **Type**, **Region** or **Country**, **ABV**, **Size**, **Price paid** (amount, shop, month and year). Leave out rows you can't source rather than guessing. Extra rows such as **Casks** are fine when the label gives them.
4. `## Tasting Notes`: separate `**Nose:**`, `**Palate:**` and `**Finish:**` paragraphs.
5. `## Pairing`: only if he mentioned one.
6. `## Verdict`: his conclusion. Follow-ups he posted later go here.
7. The last line is always `Sláinte! 🥃`.

Cross-link related posts (same brand, same distillery, same shopping trip) with root-relative links such as `[Teacher's](/posts/teachers-highland-cream-tasting-notes/)`, and check that the target exists.

### Images

- Every post should have a cover at `images/cover.webp`, referenced as `featuredImage: "posts/<slug>/images/cover.webp"`. The theme renders it above the post.
- Other images get descriptive kebab-case names and are embedded as `![alt text](./images/<name>.webp)`. Always write real alt text.
- Prefer Arda's own photos. Use stock, retailer or watermarked images only when Arda provides them himself. Then credit every one:
  - right under an inline image: `*Photo: [Source name](source URL)*`
  - for the cover, which the theme shows without a caption, in the body text, for example "The cover photo is from [The Whisky Exchange](URL)."
- If there's no usable photo, leave out `featuredImage`. Never use an unrelated image.
- Every image is WebP, fits within 1280×1280, and is compressed with TinyPNG (usually under about 100 KB). Keep downloaded or original images in a temporary folder outside the repo, and commit only the final `.webp` files.

### TinyPNG compression

- The API key lives in `~/.config/tinify/key` (mode 600). Arda may delete it after use. If it's missing, stop and ask him to recreate it; he can copy the key from https://tinify.com/dashboard/api.
- Never print the key, put it on a command line, commit it, or include it in a pull request. Pass it to curl as a config file on stdin (`-K -`), as below.
- Billing: in practice each image costs 2 compressions: 1 for the upload and 1 for the output request, whether it converts only or resizes and converts in one call. The free plan gives 500 a month, and the `Compression-Count` response header shows this month's usage. Only include `resize` when the image is bigger than 1280 px on either side.

```bash
key_cfg() { printf 'user = "api:%s"\n' "$(tr -d '\n\r ' < ~/.config/tinify/key)"; }

# 1. Upload. The output URL comes back in the Location header (HTTP 201).
loc=$(key_cfg | curl -sS -K - --data-binary @original.jpg -D - -o /dev/null https://api.tinify.com/shrink \
  | awk 'tolower($1)=="location:"{print $2}' | tr -d '\r')

# 2. Convert to WebP (drop "resize" if the image already fits in 1280x1280) and download it.
key_cfg | curl -sS -K - -H 'Content-Type: application/json' \
  --data '{"resize":{"method":"fit","width":1280,"height":1280},"convert":{"type":"image/webp"}}' \
  -o content/posts/<bundle>/images/cover.webp "$loc"

file content/posts/<bundle>/images/cover.webp   # must say "Web/P image"
```

### Before opening the pull request

- `hugo list all | grep <slug>` lists the post.
- Every `featuredImage`, inline image and internal link points to a file or post that exists.
- The front matter has the `Drinks` category, the drink-type tag and `english`.
- The pull request description lists the posts (and any drafts), the image sources, and anything Arda should double-check: editorial changes, label corrections, unclear sentences.
