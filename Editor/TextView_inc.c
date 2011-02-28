#include "clutter/clutter.h"

extern void editor_text_view_text_inserted ();

void editor_text_view_register_insert_text_signal (GObject * text) {
    g_signal_connect(CLUTTER_TEXT(text),
            "insert-text",
            G_CALLBACK(editor_text_view_text_inserted),
            NULL);
}
