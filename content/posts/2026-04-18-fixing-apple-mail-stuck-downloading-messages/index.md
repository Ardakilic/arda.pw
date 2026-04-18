---
title: "Fixing Apple Mail When It’s Stuck on Downloading Messages"
date: 2026-04-17T20:00:00+03:00
lastmod: 2026-04-17T20:00:00+03:00
draft: false

description: "Apple Mail shows 'Downloading messages' but nothing arrives? Here’s how I debugged and fixed a broken sync state after a fresh macOS setup."

tags:
  - macos
  - apple mail
  - debugging
  - imap
  - gmail
  - cloudkit

categories:
  - debugging
  - macos

keywords:
  - apple mail stuck downloading
  - mail app not syncing mac
  - apple mail not downloading messages
  - macos mail imap issue
  - gmail apple mail fix

author: "Arda"

slug: "fixing-apple-mail-stuck-downloading-messages"
featuredImage: "posts/fixing-apple-mail-stuck-downloading-messages/images/cover.webp"
---

# Fixing Apple Mail When It’s Stuck on “Downloading Messages”

I ran into one of those bugs that slowly drives you insane.

I had just formatted my Mac. Fresh install, clean setup, everything working great. I added my accounts to Mail.app, opened it, and it looked… perfect.

Folders were there. Inbox counts looked correct. It even said:

> *“Downloading messages… 5,379 new messages”*

Nice.

Except… nothing showed up.

No emails. No progress. Just a spinner pretending to work.

---

## 🤨 Something Felt Off

At first, I didn’t question it.

* Maybe Gmail is slow
* Maybe Apple servers are lagging
* Maybe it just needs time

So I waited.

Nothing.

Then I checked disk usage:

```bash
du -sh ~/Library/Mail
```

Output:

```text
4.4M    ~/Library/Mail
```

That’s basically empty.

For thousands of emails, that folder should be **huge**.

That’s when it clicked:

> Mail wasn’t downloading anything. It just *thought* it was.

---

## 🧠 First Suspect: Permissions (TCC Rabbit Hole)

Since this was a fresh macOS install, I suspected permissions.

I tried listing the Mail directory:

```bash
ls ~/Library/Mail
```

Got:

```text
Operation not permitted
```

That usually means macOS privacy (TCC) is blocking access.

So I:

* Gave my terminal Full Disk Access
* Retried → it worked

Then I thought:

> Maybe Mail itself is stuck in a weird permission state?

So I reset its permissions:

```bash
tccutil reset All com.apple.mail
```

Restarted Mail…

Still stuck.

---

### 💡 Important realization

This was a **false lead**.

* Terminal being blocked is normal without Full Disk Access
* Mail.app already has the permissions it needs

👉 So this didn’t explain the issue — it just helped rule things out

---

## 🔍 The Turning Point: Logs

At this point, I stopped guessing and looked at logs:

```bash
log stream --style syslog \
--predicate '(process == "Mail") || (process == "accountsd") || (process == "cloudd")'
```

Triggered a sync and watched.

---

### What I expected

```text
FETCH ...
BODY[]
```

That’s Mail actually downloading messages.

---

### What I actually saw

```text
STATUS Inbox
STATUS Archive
Background fetch completed
```

No `FETCH`. No downloads.

---

## 🧠 What That Means

Apple Mail works in phases:

1. Connect to server
2. Fetch mailbox metadata (`STATUS`)
3. Download messages (`FETCH`)

In my case:

* Connection: ✅
* Metadata (folders, counts): ✅
* Message download: ❌

---

### 🔑 Key insight

You’ll often see:

* `STATUS` → mailbox counts
* `IDLE` → waiting for updates
* ❌ **no `FETCH`**

That means:

> Mail knows messages exist, but never tries to download them

---

## 💥 The Real Problem

At this point I ruled out:

* ❌ Network
* ❌ Authentication
* ❌ Permissions

Which leaves:

> **Broken IMAP sync state**

More specifically:

* UID tracking got out of sync
* Mail believed everything was already downloaded
* Server disagreed
* Mail never issued `FETCH` requests

---

## 🛠️ Things I Tried (Didn’t Work)

Before fixing it, I went through:

* Restarting Mail
* Restarting macOS
* Rebuilding mailboxes
* Resetting TCC permissions

None of these helped.

Because the problem wasn’t surface-level — it was internal sync state.

---

## 💣 The Fix That Actually Worked

At this point I stopped trying to patch it and just reset Mail completely.

---

### 1. Quit Mail

```bash
killall Mail
```

---

### 2. Backup & remove Mail state

*(Safer than deleting outright)*

```bash
mv ~/Library/Mail ~/Desktop/Mail_backup
mv ~/Library/Containers/com.apple.mail ~/Desktop/com.apple.mail.backup
mv ~/Library/Group\ Containers/group.com.apple.mail ~/Desktop/group.com.apple.mail.backup
```

---

### 3. Restart background services

```bash
killall accountsd
killall cloudd
killall bird
```

---

### 4. Re-add accounts

Go to:

**System Settings → Internet Accounts**

* Remove your accounts
* Add them again

👉 This step is important — it resets sync + auth state

---

## ✅ What “Fixed” Looks Like

Opened Mail again.

This time:

* Disk usage started increasing
* Emails actually appeared
* Logs showed:

```text
FETCH
BODY[]
```

That’s the signal everything is finally working.

---

## ⚠️ Small Warning

If you have:

* local-only mailboxes
* unsynced drafts

Back them up before resetting.

This process wipes Mail’s local state.

---

## 🚫 What This Is *Not*

This bug is misleading.

It looks like:

* permissions
* network
* Gmail issue

But it’s none of those.

---

## 🧾 TL;DR

If Mail says it’s downloading but nothing shows up:

* Check disk usage (`~/Library/Mail`)
* Check logs for missing `FETCH`
* Don’t get stuck on permissions
* Reset Mail state + re-add accounts

---

## 💭 Final Thought

This is one of those bugs where everything *looks* fine:

* No errors
* No warnings
* No crashes

But one critical thing is missing.

In my case, it was a single word in the logs:

> `FETCH`

And once you notice that, everything else makes sense.

---

Happy debugging 👨‍💻
