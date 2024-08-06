MERCURY=../../../../bin/mercury.sh

# List of generated specification files.
all:	echo_server-api.ads

.PHONY: clean

clean:
	rm -f *.ads *.adb

echo_server-api.ads:	Echo_Server.mxdr
	$(MERCURY) $^
