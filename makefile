.PHONY: all
all: posts/rss.xml readme.md

posts/list.yml: generate.sh posts/*.md
	./generate.sh list $(filter-out $<,$^) > $@

posts/rss.xml: generate.sh templates/rss.xml posts/list.yml
	./generate.sh tpl $(filter-out $<,$^) > $@

readme.md: generate.sh templates/readme.md posts/list.yml
	./generate.sh tpl $(filter-out $<,$^) > $@
