all: celloParser

celloParser: celloParser.cpp
	g++ -L/usr/local/lib `xml2-config --cflags` `xml2-config --libs` -o celloParser celloParser.cpp -lDataSeries

clean:
	rm -rf *o celloParser
