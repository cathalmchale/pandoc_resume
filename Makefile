OUT_DIR=output
IN_DIR=markdown
STYLES_DIR=styles
STYLE=chmduquesne

all: html pdf docx rtf

pdf: init
	pandoc --standalone --template $(STYLES_DIR)/$(STYLE).tex \
		--from markdown --to context \
		--variable papersize=A4 \
		--output $(OUT_DIR)/resume.tex \
		$(IN_DIR)/header.md $(IN_DIR)/education.md $(IN_DIR)/technology.md $(IN_DIR)/jobs.md $(IN_DIR)/other-jobs.md $(IN_DIR)/projects.md $(IN_DIR)/break.md $(IN_DIR)/workplace.md $(IN_DIR)/footer.md \
		> /dev/null; \
	sed -i 's/\(REPLACE_NEWPAGE\)/\\page[yes]/g' $(OUT_DIR)/resume.tex > /dev/null; \
	context $(OUT_DIR)/resume.tex \
		--result=$(OUT_DIR)/resume.pdf > $(OUT_DIR)/context_resume.log 2>&1; \

html: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.html; \
		pandoc --standalone --include-in-header $(STYLES_DIR)/$(STYLE).css \
			--lua-filter=pdc-links-target-blank.lua \
			--from markdown --to html \
			--output $(OUT_DIR)/$$FILE_NAME.html $$f; \
	done

docx: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.docx; \
		pandoc --standalone $$SMART $$f --output $(OUT_DIR)/$$FILE_NAME.docx; \
	done

rtf: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.rtf; \
		pandoc --standalone $$SMART $$f --output $(OUT_DIR)/$$FILE_NAME.rtf; \
	done

init: dir version

dir:
	mkdir -p $(OUT_DIR)

version:
	PANDOC_VERSION=`pandoc --version | head -1 | cut -d' ' -f2 | cut -d'.' -f1`; \
	if [ "$$PANDOC_VERSION" -eq "2" ]; then \
		SMART=-smart; \
	else \
		SMART=--smart; \
	fi \

clean:
	rm -f $(OUT_DIR)/*
