ALL=$(wildcard *.sty *.tex chapters/*.tex)
MAIN=$(wildcard *.tex)
PDF=$(patsubst %.tex,%.pdf,$(MAIN))
LATEX=xelatex -file-line-error -interaction=nonstopmode -halt-on-error \
	  -shell-escape -synctex=1
TIME=env time -p
SHELL=/bin/zsh

all: $(PDF)

$(PDF): $(ALL)
	$(LATEX) $(MAIN) || (if [[ "$$?" -ne "0" ]]; then printf "\a"; fi)

watch:
	echo $(ALL) \
		| tr ' ' '\n' \
		| entr -cd $(TIME) make all
