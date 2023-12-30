---
title: 'Laravel ile SMS Gönderme: Mutlucell SMS'
description: >-
  Bugün sizlere Laravel için hazırladığım yeni kütüphaneden bahsetmek
  istiyorum.
date: '2014-05-21T14:36:57.000Z'
author: ["Arda Kılıçdağı"]
categories: ["development"]
keywords: ["laravel", "php", "sms", "mutlucell", "türkçe"]
# featuredImage: "posts/laravel-ile-sms-gonderme-mutlucell-sms/images/laravel-logo.png"
slug: laravel-ile-sms-gonderme-mutlucell-sms
draft: false
---

![laravel logo](./images/laravel-logo.png)

Bugün sizlere Laravel için hazırladığım yeni kütüphaneden bahsetmek istiyorum.

[Laravel-Mutlucell-SMS](https://github.com/Ardakilic/laravel-mutlucell-sms) adını koyduğum bu paket ile Laravel bazlı projelerinizde

* Tekli veya çoklu SMS gönderebilir,
* Bu çoklu sms leri farklı kişilere gönderebilir,
* İleri tarihe sms gönderimi ayarlayabilir
* Bakiye bilgisi alabilir,
* Farklı originatörler kullanabilirsiniz.

### Kurulum

* Şu komutla `composer require ardakilic/mutlucell` paketi ekleyin. Uygun versiyon gelecektir.
* Şimdi (sadece çok eski sürümlerde) de `config/app.php` dosyasını açın, `providers` içine yoksa en alta şunu girin:
* `'Ardakilic\Mutlucell\MutlucellServiceProvider',`
* Şimdi yine aynı dosyada `aliases` altına şu değeri girin:
* `'Mutlucell' => 'Ardakilic\Mutlucell\Facades\Mutlucell',`
* Şimdi de environment’ınıza konfigürasyon dosyasını paylaşmalısınız. Bunun için aşağıdaki komutu çalıştırın:
* `php artisan vendor:publish`
* `config` klasörü altına `mutlucell.php` dosyası paylaşılacak. Burada Mutlucell için size atanan kullanıcı adı, parola ve sender_id (originator) değerlerini girmelisiniz.

### Kullanım

[GitHub Sayfası](https://github.com/Ardakilic/laravel-mutlucell-sms#kullan%C4%B1m)’ndaki kullanım aşamasından doğrudan örnekleri inceleyebilirsiniz.

**Afiyet olsun! :)**