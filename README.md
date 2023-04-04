# luametatex 相關設定
* 集成了 liyanrui 的 [zhfonts](https://github.com/liyanrui/zhfonts)
# ConText 相關文檔：https://tex.stackexchange.com/questions/448812/the-definitive-guide-to-context-mkiv-and-lmtx-documentation
# 字體依賴：
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
# 安裝ConText
# 已集成metauml
* 修復了log重定義的錯誤：overloading permanent 'log'
```
find -type f|xargs sed -i "s/^\( *\)log /\1metauml_log /"
```
* 修復了 boxes 相關的錯誤
