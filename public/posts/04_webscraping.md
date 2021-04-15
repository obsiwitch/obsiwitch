---
title: Automate downloads
date: 2020-09-04
---

# Dotxpathdl

I wrote dotxpathdl first as a [cli tool](https://gitlab.com/Obsidienne/dotfiles/-/blob/163b023baec5613d1e5f64a58dcf6de66f000d98/user/bin/dotxpathdl) and then as a [python module](https://gitlab.com/Obsidienne/dotfiles/-/blob/a86e690017f57eb7a3b1e6b7f70e4005efc4e183/user/lib/python/dotxpathdl.py) to download files on a sequence of pages (e.g. webcomics) with the help of XPath expressions. The module navigates to `start_url`, retrieves file URLs with `elem_xpath`, downloads them, goes to the next page by retrieving its url with `next_xpath`, and repeats the previous steps until there is no next page.

```py
from dotxpathdl import Downloader as Xpdl

url = 'https://www.webtoons.com/en/supernatural/muted/episode-1/viewer?title_no=1566&episode_no=1'

# Fails: download 'bg_transparency.png' (1x1 transparent png image) 80
# times because the src attribute was not set due to JavaScript not being
# interpreted.
Xpdl(url, '//div[@id="_imageList"]/img/@src').start()

# Fails: download "Referral Denied" error webpage 80 times due to missing
# referer HTTP header.
Xpdl(url, '//div[@id="_imageList"]/img/@data-url').start()

# Works: download works after adding the expected referer to the HTTP request
# header.
Xpdl(
    start_url  = url,
    elem_xpath = '//div[@id="_imageList"]/img/@data-url',
    next_xpath = '//a[contains(@class, "pg_next _nextEpisode")]/@href',
    headers    = { 'referer': 'https://www.webtoons.com/' },
).start()
```

# Browser Web Console

The script above can't handle websites loading their content via JavaScript.  We can solve this problem by automating downloads in the browser. It will also be easier to handle scenarios where authentication is needed. First of all I created a new Firefox profile (`firefox --ProfileManager`) to avoid modifying my main profile preferences.

We would like to download a file from a link on a page by using JavaScript and the browser's web console (F12).

```js
// example: https://www.archlinux.org/packages/core/x86_64/bash/
document.querySelector('#actionlist li:last-child a').click()
```

It works with this specific example, but there are two problems with the above code. First, the browser might try to preview the file instead of downloading it (e.g. images, PDFs). Second, it displays the save dialog instead of starting the download automatically which is a problem if we need to download a large number of files.

We can solve the first problem by adding the `download` attribute to the link. But it will only work if the file is stored on the same domain as the webpage we are currently viewing.

```js
// example: https://www.gnu.org/
let img = document.querySelector('img')
let a = document.createElement('a')
a.href = img.src
a.download = ''
a.click()
```

As mentioned above, the `download` attribute doesn't work for cross origin sites ([bugzilla](https://bugzilla.mozilla.org/show_bug.cgi?id=874009)). To bypass this restriction we can fetch the resource and create a link to the URL of the retrieved blob.

```js
// Example: https://www.webtoons.com/en/supernatural/muted/episode-1/viewer?title_no=1566&episode_no=1
let img = document.querySelector('#_imageList img')
fetch(img.src)
    .then(response => response.blob())
    .then(blob => {
        let a = document.createElement('a')
        a.href = URL.createObjectURL(blob)
        a.download = ''
        a.click()
    })
```

It works, but now we would like to download all the files from a page without displaying the save dialog. The quickest and easiest way is probably to add the MIME types we would like to download automatically to Firefox preferences. You can set them in `about:preferences` (Action: Save File), but you need to have encountered the type at least once for it to appear in the list. These settings are saved in your Firefox profile directory in `handlers.json`. You can also set `browser.helperApps.neverAsk.saveToDisk` in `about:config` to a comma-separated list of MIME types (e.g. `image/jpeg,image/png`) to achieve the same result.

```js
// Example: https://www.webtoons.com/en/supernatural/muted/episode-1/viewer?title_no=1566&episode_no=1
document.querySelectorAll('#_imageList img').forEach((img, i) => {
    fetch(img.src)
        .then(response => response.blob())
        .then(blob => {
            let a = document.createElement('a')
            a.href = URL.createObjectURL(blob)
            let path = new URL(img.src).pathname
            path = path.substring(path.lastIndexOf('/') + 1)
            a.download = `${i.toString().padStart(3, '0')}_${path}`
            a.click()
        })
})
```

We now know how to automate downloads on one page, but how do we handle a sequence of pages or more complex scenarios?

# Userscripts

We can use an extension to write and execute userscripts to scrape multiple pages ([Greasemonkey](https://addons.mozilla.org/en-US/firefox/addon/greasemonkey/) or [Violentmonkey](https://addons.mozilla.org/en-US/firefox/addon/violentmonkey/)).

```js
// ==UserScript==
// @name Scrape webtoon
// @match *://www.webtoons.com/*/viewer*#monkey
// ==/UserScript==

// Example: https://www.webtoons.com/en/supernatural/muted/episode-1/viewer?title_no=1566&episode_no=1#monkey

window.ulocation = new URL(window.location)
let epi = ulocation.searchParams.get('episode_no')
epi = epi.toString().padStart(3, '0')

let promises = []
document.querySelectorAll('#_imageList img').forEach((img, imgi) => {
    let p = fetch(img.src)
        .then(response => response.blob())
        .then(blob => {
            let a = document.createElement('a')
            a.href = URL.createObjectURL(blob)
            imgi = imgi.toString().padStart(3, '0')
            let path = new URL(img.src).pathname
            path = path.substring(path.lastIndexOf('/') + 1)
            a.download = `${epi}_${imgi}_${path}`
            a.click()
        })
    promises.push(p)
})

Promise.all(promises)
    .then(_ => window.location = document.querySelector('a.pg_next').href + '#monkey')
```

The `@match` metadata key describes which pages the script should be executed on. The script will only execute on webtoon comic pages and only if the `#monkey` anchor is added at the end of the URL. By adding the anchor rule, we can control when we want to start the download without interfering with normal web browsing.

Once all the image fetches have been resolved, we retrieve the next page URL, append the `#monkey` anchor to it and redirect the browser to it. The userscript then executes again on the new page because it also matches the `@match` rule of the script.

You might also want to add a delay between your requests to avoid overloading the web server and/or getting your IP blocked. The example below waits 5 seconds (arbitrarily) before redirecting to the next page.

```js
// ...

Promise.all(promises)
    .then(_ => new Promise(resolve => setTimeout(resolve, 5000)))
    .then(_ => window.location = document.querySelector('a.pg_next').href + '#monkey')
```

**Note**: I didn't have any useful examples to demonstrate its use but you might need [MutationObserver](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver) to wait for changes to the DOM tree.

# Selenium

Selenium is a browser automation tool (e.g. for web applications testing purposes). I'm using the [python binding](https://archlinux.org/packages/community/x86_64/python-selenium/) of selenium with [geckodriver](https://archlinux.org/packages/community/x86_64/geckodriver/). [This example](https://gitlab.com/Obsidienne/codeexperiments/-/blob/285eff138b78013f2b817e8d01307b3b61fabaca/Snippets/SeleniumScraping.py) creates a firefox profile with `browser.helperApps.neverAsk.saveToDisk` set and launches the browser. The script first bypasses webtoons' age gate by filling the form and then downloads the webcomic using code similar to the one in the previous section.

# Post-processing with Bash

```bash
# move each episode in its own subdirectory
for f in *_*_*; do
    episode="e${f%%_*}"
    mkdir -p "$episode"
    mv "$f" "$episode"
done

# create one cbz file per webtoon episode
# note: apack is provided by the atool package in most linux distributions
for d in e*; do
    apack -F zip "$d.cbz" "$d"
done
```
