# requirements:
# 1. dir_main
# 2. tex_path
# 3. doc_env
# 4. pdf_name
# 5. LMTX_DIR
# 6. FONT_DIR
# 7. CONTEXT_BIN
ifeq ("${dir_main}", "")
$(error "must assign `dir_main'")
endif
ifeq ("${tex_path}","")
tex_path:=${dir_main}/main.tex
endif
ifeq ("${doc_env}", "")
doc_env:=null
endif
ifeq ("${pdf_name}","")
pdf_name:=main
endif
ifeq ("${LMTX_DIR}", "")
LMTX_DIR:=/usr/share/texmf-dist/texmf-context
endif
ifeq ("${FONT_DIR}", "")
FONT_DIR+=/usr/share/fonts/noto-cjk:/usr/share/fonts/noto:/usr/share/fonts/Adobe:/usr/share/fonts/adobe-source-code-pro
endif
ifeq ("${CONTEXT_BIN}", "")
CONTEXT_BIN:=/usr/local/bin/context
endif
ifeq ("${MTXRUN_BIN}", "")
MTXRUN_BIN:=/usr/local/bin/mtxrun
endif

__dir_output := ${dir_main}/output

__dir_env := $(dir $(lastword $(MAKEFILE_LIST)))
__dir_cn_env := ${__dir_env}/cn
__dir_en_env := ${__dir_env}/en

__dir_jiazhu := ${__dir_env}/modules/jiazhu
__dir_vertical-typesetting := ${__dir_env}/modules/vertical-typesetting
__dir_zhfonts := ${__dir_env}/modules/zhfonts
__dir_zhpunc := ${__dir_env}/modules/zhpunc
__dir_zhfonts-liyanrui := ${__dir_env}/modules/zhfonts-liyanrui

__dir_metapost := ${__dir_env}/metapost
__dirs_metapost_modules := ${__dir_metapost}/metauml
#__dir_zh_modules := ${__dir_jiazhu},${__dir_vertical-typesetting},${__dir_zhfonts},${__dir_zhpunc}
__dir_zh_modules := ${__dir_zhfonts-liyanrui}

__dir_figs := ${dir_main}/figs

__paths_cn_env := ${__dir_zh_modules},${__dir_cn_env},${__dirs_metapost_modules},${__dir_figs}
__paths_en_env := ${__dir_en_env}

__tex_deps:=$(shell find ${__dir_env} \
	-regextype posix-extended \
	-regex ".*\.(tex|mp|bib|lua|mkiv|mkxl)")
__tex_deps+=$(shell find ${dir_main} \
	-regextype posix-extended \
	-regex ".*\.(tex|mp|bib|lua|mkiv|mkxl)")

# key0=value0,key1=value1,...
__arguments := 

.PHONY: all
all: ${__dir_output}/${pdf_name}.pdf

.PHONY: clean
clean:
	@rm -rf ${__dir_output}/*

${__dir_output}/${pdf_name}.pdf: $(__tex_deps) | ${__dir_output}/
	echo [gen] $@; \
	export TEXMF=${LMTX_DIR}; \
	export OSFONTDIR=${FONT_DIR}; \
	cd ${__dir_output}; \
	${CONTEXT_BIN} \
		--nocompression \
		--environment=env_${doc_env} \
		--path=${__paths_cn_env} \
		--result=${pdf_name}.pdf \
		--arguments=${__arguments} \
		${tex_path}

.PHONY: generate
generate:
	export TEXMF=${LMTX_DIR}; \
	export OSFONTDIR=${FONT_DIR}; \
	mtxrun --script fonts --reload; \
	mtxrun --script font --list --all; \
	${MTXRUN_BIN} --generate; \
	${MTXRUN_BIN} --script font --reload --force; \
	${MTXRUN_BIN} --script font --list --all

${__dir_output}/:
	@mkdir -p $@
