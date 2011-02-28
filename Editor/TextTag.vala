namespace Editor {
    class TextTag : GLib.Object {
        string name;
        string font_family;

        public TextTag(string n, string f) {
            name = n;
            font_family = f;
        }
    }
}
