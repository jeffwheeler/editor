using Gtk;
using Pango;

namespace Editor {
    class TextLayout : GLib.Object {
        TextBuffer buffer;

        public TextLayout(TextBuffer buffer) {
            this.buffer = buffer;
        }
    }
}
