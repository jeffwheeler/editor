VC=valac
VCFLAGS=--pkg gee-1.0 --pkg gtk+-3.0 --pkg clutter-1.0

.PHONY: clean

main: main.vala Editor/*.vala Editor/TextView_inc.c
	$(VC) $(VCFLAGS) main.vala Editor/*.vala Editor/TextView_inc.c

clean:
	rm -f main
