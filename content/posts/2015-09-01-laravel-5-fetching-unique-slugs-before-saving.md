---
title: 'Laravel 5: Fetching unique slugs before saving'
description: 'Hello, Today, I’ll try to tell about a little tiny trick about PHP traits using Laravel as example.'
date: '2015-09-01T08:36:08.000Z'
author: ["Arda Kılıçdağı"]
categories: ["development"]
keywords: ["laravel", "php", "slug", "english"]
slug: laravel-5-fetching-unique-slugs-before-saving
draft: false
---

Hello,

Today, I’ll try to tell about a little tiny trick about PHP traits using Laravel as example.

I’ll rename a private method in PHP traits and use it like a public method.

There is an awesome package for Laravel called [Eloquent-Sluggable](https://github.com/cviebrock/eloquent-sluggable) created by Colin Viebrock, which I’ve been using since Laravel 4.

I couldn’t find a similar article for the same purpose with this package, so I decided to write a simple blog post.

Today, in a project, I needed to create the slug before saving. First, I thought of running the method directly in a model, so I tried running

```php
Model::makeSlugUnique('my-slug-that-may-not-be-unique');
```

But as expected, it failed, because its property was `protected`, and I should not fetch non static method statically.

So I tried this as a second attempt: I’ve changed the `use SluggableTrait;` trait line `Model.php` like this:

```php
use SluggableTrait { makeSlugUnique as public; }
```

But it failed as expected.

So I’ve decided to rename the method. This is what I did:

```php
use SluggableTrait { makeSlugUnique as uniqueSlug; }
```

and When I run this,

```php
Model::uniqueSlug('my-slug-that-may-not-be-unique');
```

It returns me `my-slug-that-may-not-be-unique-1` with a suffix and separator that respects my settings that I've set in model.