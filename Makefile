rainyday:
	xcodebuild

clean:
	xcodebuild clean

distclean: clean
	rm -rf build

.PHONY: rainyday clean distclean
