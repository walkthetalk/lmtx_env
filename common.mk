# requirements:
# 1. dir_main
# 2. tex_path
# 3. doc_env
# 4. pdf_name
ifeq ("${dir_main}", "")
$(error "must assign `dir_main'")
endif
ifeq ("${output_dir}", "")
output_dir := ${dir_main}/output
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
ifeq ("${TEXLIVE_DIR}","")
TEXLIVE_DIR:="/opt/texlive/2024"
endif
ifeq ("${TEXLIVE_FONT_DIR}","")
TEXLIVE_FONT_DIR := /opt/texlive/fonts
# archlinux
TEXLIVE_FONT_DIR := ${TEXLIVE_FONT_DIR}:/usr/share/fonts/noto-cjk:/usr/share/fonts/noto:/usr/share/fonts/Adobe
# ubuntu
TEXLIVE_FONT_DIR := ${TEXLIVE_FONT_DIR}:/usr/share/fonts/opentype/noto
endif
ifeq ("${EXTRA_PATH}", "")
EXTRA_PATH:=
endif

# NOTE: the default shell is dash on ubuntu
SHELL := /usr/bin/env bash

# self dir
__common_mk_path := $(abspath $(lastword $(MAKEFILE_LIST)))
__common_mk_dir := $(dir $(__common_mk_path))
__tl_script_path := ${__common_mk_dir}/set_texlive_env.sh

CMD_SET_LMTX_ENV:=source ${__tl_script_path} ${TEXLIVE_DIR} ${TEXLIVE_FONT_DIR}

# settings
main_object := ${output_dir}/${pdf_name}.pdf

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
__dir_zh_modules := ${__dir_jiazhu},${__dir_vertical-typesetting},${__dir_zhfonts},${__dir_zhpunc}

__dir_figs := ${dir_main}/figs

__paths_cn_env := ${__dir_zh_modules},${__dir_cn_env},${__dirs_metapost_modules},${__dir_figs}
ifneq ("${EXTRA_PATH}", "")
__paths_cn_env :=${__paths_cn_env},${EXTRA_PATH}
endif
__paths_en_env := ${__dir_en_env}

__tex_deps:=$(shell find ${__dir_env} \
	-regextype posix-extended \
	-regex ".*\.(tex|mp|bib|lua|mkiv|mkxl|mklx)")
__tex_deps+=$(shell find ${dir_main} \
	-regextype posix-extended \
	-regex ".*\.(tex|mp|bib|lua|mkiv|mkxl|mklx)")

# key0=value0,key1=value1,...
__arguments := 

define define_object =
.PHONY: $1
$1: $${output_dir}/$1.pdf

$${output_dir}/$1.pdf: $${dir_main}/$2 | $${output_dir}/
	echo [gen] $$@; \
	$${CMD_SET_LMTX_ENV}; \
	cd $${output_dir}; \
	context \
		--nocompression \
		--environment=env_$${doc_env} \
		--path=$${dir_main},$${},$${__paths_cn_env} \
		--result=$1.pdf \
		--arguments=$${__arguments} \
		$$<
endef

.PHONY: all
all: ${main_object}

.PHONY: clean
clean:
	@rm -rf $(output_dir) $(clean_extra)

${main_object}: $(tex_path) $(__tex_deps) | ${output_dir}/
	echo [gen] $@; \
	${CMD_SET_LMTX_ENV}; \
	cd ${output_dir}; \
	context \
		--nocompression \
		--environment=env_${doc_env} \
		--path=${dir_main},${},${__paths_cn_env} \
		--result=${pdf_name}.pdf \
		--arguments=${__arguments} \
		$<

.PHONY: generate
generate:
	${CMD_SET_LMTX_ENV}; \
	mtxrun --generate; \
	mtxrun --script font --reload --force

.PHONY: listfonts
listfonts:
	${CMD_SET_LMTX_ENV}; \
	mtxrun --script font --list --all

.PHONY: update
update:
	${CMD_SET_LMTX_ENV}; \
	tlmgr --gui

${output_dir}/:
	@mkdir -p $@
