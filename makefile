install:
	bin/composer install

start:
	"Je commence"
	php -S localhost:8080
	"J'ai finis"

test:
	# cd tst && ../vendor/bin/phpunit
	./vendor/bin/phpunit tst

lint:
	echo "=== PHP INIT ==="
	echo "début PHP Lint"
	find . -type f -name '*.php' -not -path "./vendor/*" -exec php -l {} \;
	echo "fin PHP Lint"
	echo "début PHP Code Sniffer"
	./vendor/bin/phpcs --extensions=php ./lib/
	echo "fin PHP Code Sniffer"
	echo "début PHP Mess Detector"
	./vendor/bin/phpmd ./lib ansi codesize,unusedcode,naming
	echo "fin PHP Mess Detector"
	echo "=== PHP INIT ==="