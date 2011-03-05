#include "clutter/clutter.h"
#include "glib.h"

extern PangoLayout* editor_text_view_get_layout(GObject* self);

glong editor_text_view_coords_to_position(GObject* self, gfloat x, gfloat y) {
    PangoLayout* layout = editor_text_view_get_layout(self);
    gint px = (int)(x*PANGO_SCALE), py = (int)(y*PANGO_SCALE);
    gint index, trailing;

    pango_layout_xy_to_index(layout, px, py, &index, &trailing);
    const char* utf8 = pango_layout_get_text(layout);
    return g_utf8_pointer_to_offset(utf8, utf8 + index + trailing);
}
