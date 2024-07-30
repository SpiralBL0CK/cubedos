
# Adjust to reflect Mercury's location.
MERCURY=../../../../bin/mercury.sh

# List of generated specification files.
all:	camera-api.ads

.PHONY: clean

clean:
	rm -f *.ads *.adb

camera-api.ads:	Camera.mxdr
	$(MERCURY) $^
