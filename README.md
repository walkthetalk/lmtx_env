# https://tex.stackexchange.com/questions/448812/the-definitive-guide-to-context-mkiv-and-lmtx-documentation
# 依賴：
* noto-fonts
* noto-fonts-cjk
* noto-fonts-emoji
* adobe-source-serif-fonts
* adobe-source-sans-fonts
* adobe-source-code-pro-fonts
* ttf-adobe-kaiti
* ttf-adobe-heiti
* ttf-adobe-song
* ttf-adobe-fangsong
# install context
# copy metauml
## fix: overloading permanent 'log'
```
find -type f|xargs sed -i "s/^\( *\)log /\1metauml_log /"
```
