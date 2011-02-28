namespace Editor {
    class TextMark : GLib.Object {
        string name;
        public int position;

        public TextMark(int position) {
            this.position = position;
        }

        public TextMark.with_name(string name, int position) {
            this.name = name;
            this.position = position;
        }
    }
}
