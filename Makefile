.PHONY: autotest doc

autotest:
	./xcodetest M3Tests

clean:
	xcodebuild -configuration Debug -target M3Tests clean

# doc:
# 	appledoc -o doc --create-html --no-create-docset -p Underscore.m -c radiospiel.org underscore/underscore.h*
