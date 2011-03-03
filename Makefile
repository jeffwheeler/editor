VC=valac
VCFLAGS=--pkg gee-1.0 --pkg gtk+-3.0 --pkg clutter-1.0 --pkg GtkClutter-1.0

.PHONY: clean

main: main.vala Editor/*.vala
	$(VC) $(VCFLAGS) main.vala Editor/*.vala

clean:
	rm -f main
