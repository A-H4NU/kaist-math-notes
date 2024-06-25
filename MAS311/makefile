ALL=$(shell find -type f -name "*.tex")
MAIN=$(wildcard *.tex)
PDF=$(patsubst %.tex,%.pdf,$(MAIN))
# LATEX=xelatex -file-line-error -interaction=nonstopmode -halt-on-error \
# 	  -shell-escape -synctex=1
XELATEX=xelatex --shell-escape %O %S
MK=latexmk -pdfxe -pdfxelatex="$(XELATEX)"
MKCONT=latexmk -pvc -pdfxe -pdfxelatex="$(XELATEX)"
TIME=/bin/time -p
SHELL=/bin/zsh

all: $(PDF)

$(PDF): $(ALL)
	$(MK) $(MAIN)

watch:
	$(MKCONT) $(MAIN)

.PHONY:
clean:
	latexmk -c
