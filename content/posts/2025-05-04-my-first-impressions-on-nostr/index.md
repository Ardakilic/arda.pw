---
title: "My First Impressions of Nostr"
slug: "my-first-impressions-on-nostr"
date: 2025-05-04T13:31:53.131Z
tags: ["nostr", "decentralized", "social media", "web3", "experience", "english"]
draft: false
author: "Arda Kılıçdağı"
featuredImage: "posts/my-first-impressions-on-nostr/images/cover.webp"
---

Over the past few weeks, I’ve been actively exploring **Nostr**, a decentralized social media protocol. This post summarizes my impressions and user experience so far.

## What is Nostr?

**Nostr** stands for **Notes and Other Stuff Transmitted by Relays**. 

Nostr is a censorship-resistant, decentralized protocol for social communication. Compared to alternatives like Mastodon (based on ActivityPub), Nostr offers a much simpler yet powerful architecture. Your identity isn’t tied to a username or email address—**it's your public/private key pair**.

## Creating an Account

Getting started is remarkably easy. For example, you can visit [nostr.com](https://nostr.com) and click “Start your journey” to instantly generate a key pair. You must store these keys securely—**if you lose them, you lose access to your account**. There is no password reset or recovery option.

## How Do Relays Work?

Posts on Nostr are broadcast to **relays**, which are essentially servers that distribute content. Think of them like SMTP servers in email. You can connect to multiple relays simultaneously, and clients will fetch content from all of them.

I'm currently connected to **13 different relays**, which increases the reach and availability of my content across the network.

### My Relay List

```text
- wss://relay.primal.net
- wss://relay.damus.io
- wss://nos.lol
- wss://filter.nostr.wine
- wss://nostr-pub.wellorder.net
- wss://nostr.land
- wss://nostr.wine
- wss://purplepag.es
- wss://purplerelay.com
- wss://relay.getalby.com/v1
- wss://relay.mostr.pub
- wss://theforest.nostr1.com
- wss://relay.nos.social
````

## What About Data Persistence?

Not all relays store your posts indefinitely. Some may prune older events after a while. If persistence is important to you, consider:

* Running your own relay (public or private),
* Using premium relay services that guarantee long-term storage.

## User Experience

Nostr supports a growing number of features:

* **Client variety:** [Primal](https://primal.net) is one of the most polished and intuitive clients.
* **Basic social features:** Like, repost, quote, hashtags, lists, DMs, bookmarks, and more.
* **No character limit.**
* **Image and media support:** You can include visuals easily—some clients even offer their own image hosting. For instance, an image I uploaded to imgur appeared inline just like native media.
* **Zap (micropayments):** You can support creators directly through the Lightning Network using sats.

## NIP-05 Verification (Username Linking)

To verify your identity, Nostr supports a simple method called **NIP-05**, which links your profile to a domain you own. It works by hosting a `.well-known/nostr.json` file on your server.

### Sample `nostr.json` for Verification

```json
{
  "names": {
    "arda": "2c5788f9add2d7919ee28d225799c96f99128614f9a1ebda3fbc7adb0b8c4bbb"
  },
  "relays": {
    "2c5788f9add2d7919ee28d225799c96f99128614f9a1ebda3fbc7adb0b8c4bbb": [
      "wss://relay.primal.net",
      "wss://relay.damus.io",
      "wss://nos.lol",
      "wss://filter.nostr.wine",
      "wss://nostr-pub.wellorder.net",
      "wss://nostr.land",
      "wss://nostr.wine",
      "wss://purplepag.es",
      "wss://purplerelay.com",
      "wss://relay.getalby.com/v1",
      "wss://relay.mostr.pub",
      "wss://theforest.nostr1.com",
      "wss://relay.nos.social"
    ]
  }
}
```

Once hosted, you can verify your account from your client, and a verified badge will appear on your profile.

## Community & Content

Currently, the network is heavily populated by Bitcoin maximalists and Web3-savvy users. However, Nostr is open to everyone, and we’ll likely see broader adoption over time.

## My Account

🔗 Verified Profile:
[https://primal.net/p/nprofile1qqszc4uglxka94u3nm3g6gjhn8yklxgjsc20ng0tmglmc7kmpwxyhwcva0fq8](https://primal.net/p/nprofile1qqszc4uglxka94u3nm3g6gjhn8yklxgjsc20ng0tmglmc7kmpwxyhwcva0fq8)

🔑 Public Key:
`npub193tc37dd6tter8hz35390xwfd7v39ps5lxs7hk3lh3adkzuvfwaselzjc4`

---

## Final Thoughts

Nostr is still in its early days, but it’s a promising protocol that gives you full ownership of your digital identity. If you care about censorship resistance, decentralization, and open protocols, Nostr is absolutely worth exploring.

---

## 📌 Further Reading & Resources

* [NIP-05 Specification](https://github.com/nostr-protocol/nips/blob/master/05.md)
* Lightning Wallets to try: Alby, Phoenix, Wallet of Satoshi
* Relay uptime monitoring tools and curated relay lists