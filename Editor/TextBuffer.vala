using Gee;

namespace Editor {
    class TextBuffer : GLib.Object {
        HashSet<TextMark> marks;
        TextMark insert;

        HashSet<TextTag> tags;

        public TextBuffer() {
            marks = new HashSet<TextMark>();

            insert = new TextMark.with_name("insert", 0);
            marks.add(insert);

            tags = new HashSet<TextTag>();
        }

        public void move_mark_by_name(string mark_name, int position) {
            insert.position = position;
        }

        public void text_inserted(string new_text, int length, int position) {
        }

        public void text_deleted(int start, int end) {
        }
    }
}
