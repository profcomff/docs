build:
	cd scripts && ./download_apis.sh
	yfm -i ./docs -o ./dist


run: build
	http-server ./dist
