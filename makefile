.PHONY: all
all: readme.md

posts/list.yml: generate.sh posts/*.md
	./generate.sh list $(filter-out $<,$^) > $@

readme.md: generate.sh templates/readme.md posts/list.yml
	./generate.sh tpl $(filter-out $<,$^) > $@
