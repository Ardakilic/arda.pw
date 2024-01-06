---
title: 'Laravel 4: Cache + Pagination Kullanımı'
description: Bugün sizlere Laravel 4'te Cache + Pagination (sayfa numaralandırma)’nın nasıl gerçekleşeceğini anlatacağım
date: '2014-09-23T10:01:06.000Z'
author: ["Arda Kılıçdağı"]
categories: ["Development"]
tags: ["laravel", "cache", "pagination", "redis", "türkçe"]
slug: laravel-4-cache-pagination-kullanimi
# featuredImage: "posts/laravel-4-cache-pagination-kullanimi/images/laravel-logo.png"
draft: false
---

Merhaba Arkadaşlar,

Bugün sizlere Laravel 4'te Cache + Pagination (sayfa numaralandırma)’nın nasıl gerçekleşeceğini anlatacağım:

![](./images/laravel-logo.png)

[Laravel Türkiye Forumları](https://laravel.gen.tr) ve [Laravel Türkiye Facebook Sayfası](https://www.facebook.com/groups/laravelturkiye/posts/449378561868194/)’nda pek çok kez sorulan bu soruya basit bir yaklaşım kullanarak kendimce bir çözüm getirdim.

#### Nasıl?

Öncelikle yazdığım kodu yapıştırayım:

```php
<?php

/**
 * @author Arda Kılıçdağı
 * @link http://arda.pw
 */

Route::get('cache_pagination', function(){  
  //sayfa başına kaç tane olacak?
  $sayfaBasinaKacTane = 10;

  //sorgu çıktısını varsa cache'den alalım, yoksa Model'den çekip cache'e ekleyelim:
  $query = Cache::remember('koleksiyonum', 15, function(){
    return Model::sorgum(); //kendinizce bir Eloquent ya da Fluent sorgu, tümünü çekmelisiniz.
  });

  //Koleksiyonda kaç tane element var?
  $kacTaneVar = $query->count();

  //pagination classını initiate edelim
  $pagination = Paginator::make($query->toArray(), $kacTaneVar, $sayfaBasinaKacTane);

  //Koleksiyonu pagination değerine göre Slice'layalım:
  //Slice'lanmış query, view'a bu gidecek:
  $query = $query->slice(
    ($pagination->getCurrentPage()-1)*$pagination->getPerPage(),
    $pagination->getPerPage()
  );

  //Şimdi view'a yollayabiliriz:
  return View::make('frontend.index')
    ->with('data', $query)
    ->with('pagination', $pagination);
});
```

Aslında oldukça basit; Kısaca açıklamam gerekirse:

* Öncelikle Cache’den koleksiyonun tamamını alıyorum (`paginate(10)` gibi değil `get()` gibi bitmeli sorgu yani), Cache'de yoksa çekip o an Cache'e yazıyorum (örnekte 15 dakika Cache'de).
* Ardından koleksiyonda kaç adet element olduğunu alıyorum (bu değer `Pagination` sınıfını init ederken `slice()` için sınıf'a bilgi verecek)
* Bunun ardından `Pagination` sınıfını init ediyorum. Parametre tanımlarken koleksiyonu `->toArray()` ile döndürüyorum (`array_slice()` kullanıyor arka planda [bu metod](https://github.com/laravel/framework/blob/4.2/src/Illuminate/Support/Collection.php#L509-L520)). View içinde değerlere yine `$each->isim` gibi nesne şeklinde erişebilirsiniz bu sadece init ederken lazım).
* Bunun ardından slice ediyorum. Slice ederken `getCurrentPage()` metodu ile hangi sayfada olduğumu yakalıyor, bunun bir eksiği ile sayfa başına düşecek değeri çarparak hangi offsetten başlayacağımı yakalıyorum (mesela sayfa 3 için `slice()` içinde parametreler `slice((3-1)*10,10)`, yani `slice(20,10)`. Mantık olarak da 3. sayfa 20-30 arasını göstereceği için, burada da yirminci elementten başlayıp 10 tane al ve kesip bize ver diyoruz yani).
* En son olarak da slice’lanan koleksiyonu ve de `Pagination` sınıfını init ederken atadığımız `$pagination` değişkenini View'a gönderiyoruz. Bu sayede View içinde `$pagination->links()` diye pagination linklerine erişebilirsiniz.

Umarım birilerinin işine yarar.

#### Afiyet olsun ;)