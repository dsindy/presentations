dsindy-2016-02-pwl.html: README.md reveal.js
	pandoc -s -S -t revealjs $< -o $@ --mathjax

reveal.js:
	wget -q https://github.com/hakimel/reveal.js/archive/3.2.0.tar.gz
	tar zxf 3.2.0.tar.gz
	mv reveal.js-3.2.0 reveal.js
	rm -f 3.2.0.tar.gz

.PHONY:
clean:
	rm -f dsindy-2016-02-pwl.html
