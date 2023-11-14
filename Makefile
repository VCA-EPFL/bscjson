bsv2mongo:
	mkdir -p build
	bsc --aggressive-conditions -bdir build -sim -g mkTest -u Test.bsv 
	bsc -o bsv2mongo -simdir build -bdir build -sim -e mkTest

.PHONY=clean run

clean: 
	rm -f bsv2mongo bsv2mongo.so 

run: bsv2mongo
	python3 BsvDb.py &
	./bsv2mongo
