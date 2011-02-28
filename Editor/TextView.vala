using Clutter;

namespace Editor {
    class TextView : Text {
        TextBuffer buffer;

        construct {
            font_name = "OFL Sorts Mill Goudy TT Regular";

            // activatable = true;
            editable = true;
            cursor_color = Color.from_string("#50799E");
            reactive = true;
            selectable = true;
            selection_color = Color.from_string("#C0CDD9");
            use_markup = true;

            // Setup buffer
            buffer = new TextBuffer();

            cursor_event.connect(() => {
                buffer.move_mark_by_name("insert", get_cursor_position());
            });
            delete_text.connect(buffer.text_deleted);

            // In plain C, since Vala can't see the insert-text signal (name
            // collision)
            register_insert_text_signal();
        }

        extern void register_insert_text_signal();

        // Must be 'public' so that TextView_inc.c can call it
        public void text_inserted(string new_text, int length, int* position) {
            buffer.text_inserted(new_text, length, *position);
        }
    }
}
