---
title: 'Laravel 4: İlişkiler üzerinden etkin filtreleme ve gruplama'
description: >-
  Birkaç gündür Laravel 4 ile Eloquent ORM ile kompleks bir veritabanı
  ilişkilendirmesi üzerinde uğraşıyorum. Bu ilişkilendirmede şunlar…
date: '2014-03-26T10:02:42.000Z'
author: ["Arda Kılıçdağı"]
categories: ["development"]
keywords: ["laravel", "php", "rdbms"]
featuredImage: "posts/laravel-4-iliskiler-uzerinden-etkin-filtreleme-ve-gruplama/images/laravel-logo.png"
slug: laravel-4-iliskiler-uzerinden-etkin-filtreleme-ve-gruplama
draft: false
---

Birkaç gündür Laravel 4 ile Eloquent ORM ile kompleks bir veritabanı ilişkilendirmesi üzerinde uğraşıyorum. Bu ilişkilendirmede şunlar olacak:

* Bir `A` modeli üzerinde filtreleme yapılacak.
* Bu `A` modeli üzerindeki filtreleme, `B`, `C` ve `D` modelindeki ilişkilendirmelere sahip.
* Be bu ilişkilendirmelerden biri (`B` diyelim) de (`B` veya `B`'ye bağlı `B.C` ilişkisindeki koşula göre olacak).
* Bu `B`, `C` veya `D` ilişkilerinde hem `belongsTo`, hem `hasMany`, hem de `belongsToMany` ilişkisi mevcut.

![laravel logo](./images/laravel-logo.png)

Modellerde tanımlanan ilişki adlarına `modelA`, `modelB`, `modelC` ve `modelD` diyelim.

Normalde çıkan çıktıları şunun gibi alabiliyoruz:

```php
ModelA::with(
	array('ModelB' => function($query) use($inputs){
		$query->where('bKosul1', $inputs->bKosul1);
	}, 'ModelB.ModelC' => function($query) use($inputs){
		$query->where('cKosul1', $inputs->cKosul1);
	})
)
->where('modelAsutun', $inputs->modelAsutun)
->get();
```

Ama bu çıktı ana sorguda `modelAsutun` haricinde filtreleme yapmıyor, eager loading'den gelen verileri filtreliyor sadece. Kısaca işime yaramıyordu.

Düz MySQL gibi veritabanlarında spagetti kod yazarken relationlar ve gruplamalar yüklendikten sonra filtreleme yapmak için `HAVING` kullanılır.

Laravel 4.1'e kadar having metodunu kullanmanın bir yolu yoktu, sorgunun en sonuna `where('tabloadi.sütun', $deger)` yazmak gerekirdi, ORM kullanırken tablo adını yazmak da bence mantıksız olduğu kadar pivot many-to-many ilişkilerde sorun verecek bir takla idi bu.

Laravel 4.1'de gelen yeniliklerden biri olan _Constraining Eloquent ‘has’ relationships_ olayı işte tam burada devreye giriyor. [1](https://laravel.com/docs/4.2/eloquent#querying-relations).

Bu parametrelerin de filtrelenmesini sağlamak için A modeline `whereHas` komutu uygulanmalı:

Sorgu tüm ilişkileri sorgulamaya alıyor olsak şuna dönüşmeli yani:

```php
ModelA::
whereHas('modelB', function($query) use($inputs){
	$query->where('bKosul1', $inputs->bKosul1);
})
->whereHas('ModelB.ModelC', function($query) use($inputs){
	$query->where('cKosul1', $inputs->cKosul1);
})
//bir D koşulu daha ekleyelim:
->whereHas('modelD', function($query) use($inputs){
	$query->where('dKosul1', $inputs->dKosul1);
})
->where('modelAsutun', $inputs->modelAsutun)
->get();
```

_Ama bu sorguda bir hata var_, Nested relationship (`ModelB.ModelC`) `whereHas` ile kullanılamıyor! Koleksiyon hatası alacaksınız bunu denemeye kalkarsanız.

Burada aklıma ilk gelen yine Laravel 4.1'in yeniliklerinden olan `hasManyThrough` ilişkilendirme idi (`ModelB.ModelC` ilişkisine `modelBC` gibi farklı bir isim vererek nested durumdan kurtulmak), fakat bu da işe yaramıyor.

Bunu çözmenin yolu whereHas içine bir whereHas daha yazmak:

```php
ModelA::
whereHas('modelB', function($query) use($inputs){
	$query->where('bKosul1', $inputs->bKosul1);

	//Nodel B üzerinden gelen Model C'nin koşulunu Model B'nin whereHas closure'u içine yazdık:
	$query->whereHas('modelC', function($query) use($inputs){
		$query->where('cKosul1', $inputs->cKosul1);
	});
})
//bir D koşulu daha ekleyelim:
->whereHas('modelD', function($query) use($inputs){
	$query->where('dKosul1', $inputs->dKosul1);
})
->where('modelAsutun', $inputs->modelAsutun)
->get();
```

Burada şunu dedik: `ModelA` üzerinde ilişkili olan `ModelB` içinde `bKosul1` sütunu `$inputs->bKosul1` değeri ile eşleşen, `ModelB` ilişkisine bağlı `modelC` içindeki `cKosul1` sütunu `$inputs->cKosul1` değeri ile eşleşen, vede `modelD` ilişkisindeki dKosul1 sütunu `$inputs->dKosul1` sütunu ile eşleşen, ve de direkt `ModelA` içindeki `modelAsutun`'u `$inputs->modelAsutun` ile eşleşen değerleri döktük.

Buraya kadar çok güzel, fakat benim şu an üzerinde çalıştığım örneğim biraz daha karılşık.

_Öyle bir koşul yapmalıyım ki, eğer varsa, ya_ `_modelB_` _içindeki_ `_veyaliKosul_` _ilişkisi ile (pivot tablo), ya da_ `_modelD_` _içindeki_ `_dVeyaliKosul_` _sütunu (tamam, kötü isim seçtim, kabul :) ) ile ilişkilendirilmeli_

(Neden diyebilirsiniz burada, örneğimden verebileceğim detay olarak: yollanabilecek adresler ve de oturduğu yer gibi düşünün. Oturduğu yer yollanabilecek adres olabilir de olmaya da bilir, bu yüzden hem oturduğu yer, hem de yollanabilecek yerler eşleşmeli.)

Bu durumda veya koşulu için `orWhereHas` metodunu kullanıyoruz:

```php
ModelA::
whereHas('ModelB', function($query) use($inputs){
	$query->where('veyaliKosul', $inputs->veyali);
})
->orWhereHas('modelD', function($query) use($inputs){
	$query->where('dVeyaliKosul', $inputs->veyali);
}))
->where('modelAsutun', $inputs->modelAsutun)
->get();
```

Ama benim örneğimde birden fazla `whereHas` / `orWhereHas` var, bunları bir şekilde gruplamam lazım. İlk olarak gruplanacak verileri `whereHas(function($q) use($inputs){ ... })` gibi bir kod bloğu içine koylayı denedim, fakat kaynak koduna bakınca bunun desteklenmediğini gördüm. İlk parametreye ilişki adı girilmeli. _Fakat benim birden fazla ilişkiden gruplamam lazım?_

Biraz kurcalamalar sonucunda, bunları `where()` ile gruplanabileceğini fark ettim.

En son kodum şunun gibi idi:

```php
ModelA::
where(function($query) use($inputs){
	$query->whereHas('ModelB', function($query) use($inputs){
		$query->where('veyaliKosul', $inputs->veyali);
	})
	->orWhereHas('modelD', function($query) use($inputs){
		$query->where('dVeyaliKosul', $inputs->veyali);
	});
})
->whereHas('modelB', function($query) use($inputs){
	$query->where('bKosul1', $inputs->bKosul1);

	//Nodel B üzerinden gelen Model C'nin koşulunu 
	//Model B'nin whereHas closure'u içine yazdık:
	$query->whereHas('modelC', function($query) use($inputs){
		$query->where('cKosul1', $inputs->cKosul1);
	});
})
->whereHas('modelD', function($query) use($inputs){
	$query->where('dKosul1', $inputs->dKosul1);
})
->where('modelAsutun', $inputs->modelAsutun)
->get();
```

Farkındaysanız `modelB` için iki koşulum var, biri veyalı olduğundan `where()` içinde, diğeri de kendine ait, ayrıca bu modelB içinde `modelD` alt ilişkisinde de sorgu var.

Bu sayede `whereHas` gruplandığı için birden fazla `whereHas`'i kolaylıkla gruplayabilirsiniz.

Not: Bu durum pivotlarda çalışmayacaktır. Pivotlar için önce `whereIn` denedim, ama başarılı olamadım (belki bende idi hata? Geri bildirim alabilirsem memnun olurum), sonra bir dizi gibi değerlendirip gibi foreach ile döndürmek geldi aklıma:

```php
ModelA::
where(function($query) use($inputs){
	$query->whereHas('ModelB', function($query) use($inputs){
		$query->where('veyaliKosul', $inputs->veyali);
	})
	->orWhereHas('modelD', function($query) use($inputs){
		$query->where('dVeyaliKosul', $inputs->veyali);
	});
})
->whereHas('modelB', function($query) use($inputs){
	$query->where('bKosul1', $inputs->bKosul1);
 
	//Nodel B üzerinden gelen Model C'nin koşulunu 
	//Model B'nin whereHas closure'u içine yazdık:
	$query->whereHas('modelC', function($query) use($inputs){
		$query->where('cKosul1', $inputs->cKosul1);
	});
})
//Model D, Pivot tablo olsun ve de birden fazla koşulun kontrolü olsun
/*->whereHas('modelD', function($query) use($inputs){
	$query->where('dKosul1', $inputs->dKosul1);
})*/
->where(function($query) use($inputs){

	foreach ($inputs->pivotKontrolEdilecekDizi as $herBiri) {
		$query->whereHas('modelDPivottan', function($query) use($herBiri){
			$query->where('dKosul1', $herBiri);
		});
	}
})
->where('modelAsutun', $inputs->modelAsutun)
->get();
```

`ModelD`'yi incelerseniz ne demek istediğimi daha iyi göreceksiniz.

Böylece pivot verilerini de sorunsuz eklemiş oldum.

Umarım bu birilerinin işine yarar.

İyi kodlamalar ;)