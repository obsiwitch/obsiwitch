.PHONY: all
all: posts list feed index

.PHONY: posts
posts: $(patsubst %.md,%.html, $(wildcard public/posts/*.md))
public/posts/%.html: generate.sh public/templates/layout.html public/posts/%.md
	./generate.sh --post public/posts/$*.md

.PHONY: list
list: public/posts/list.yml
public/posts/list.yml: generate.sh public/posts/*.md
	./generate.sh --list

.PHONY: feed
feed: public/rss.xml
public/rss.xml: generate.sh public/templates/rss.xml public/posts/list.yml
	./generate.sh --feed

.PHONY: index
index: public/index.html
public/index.html: generate.sh public/templates/layout.html
public/index.html: public/templates/index.html public/posts/list.yml
	./generate.sh --index
