using Gtk;

using Editor;

public class EditorApp : GLib.Object {
    Window window;
    TextEditor text;

    public static int main(string[] args) {
        Gtk.init(ref args);

        EditorApp app = new EditorApp();
        app.show();

        Gtk.main();

        return 0;
    }

    construct {
        window = new Gtk.Window();
        window.destroy.connect(() => {
            Gtk.main_quit();
        });

        text = new TextEditor();
        window.add(text);

        // Add default text
        insert_default_content();
    }

    public void show() {
        window.show_all();
    }

    private void insert_default_content() {
        TextIter insert;
        text.buffer.get_iter_at_mark(out insert, text.buffer.get_insert());
        text.buffer.insert_with_tags_by_name(insert, "Think Different!\n", -1, "h1");
        text.buffer.get_iter_at_mark(out insert, text.buffer.get_insert());
        text.buffer.insert_with_tags_by_name(insert, "The Crazy Ones\n", -1, "h2");
        text.buffer.get_iter_at_mark(out insert, text.buffer.get_insert());
        text.buffer.insert_with_tags_by_name(insert, "Here’s to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes.\nThe ones who see things differently. They’re not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them.\nAbout the only thing you can’t do is ignore them. Because they change things. They invent. They imagine. They heal. They explore. They create. They inspire. They push the human race forward.\nMaybe they have to be crazy.\nHow else can you stare at an empty canvas and see a work of art? Or sit in silence and hear a song that’s never been written? Or gaze at a red planet and see a laboratory on wheels?\nWhile some see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do.\n", -1, "body");

        TextIter start, end;
        text.buffer.get_iter_at_line_index(out start, 3, 9);
        text.buffer.get_iter_at_line_index(out end, 3, 35);
        text.buffer.apply_tag_by_name("strong", start, end);

        text.buffer.get_iter_at_line_index(out start, 2, 57);
        text.buffer.get_iter_at_line_index(out end, 2, 70);
        text.buffer.apply_tag_by_name("underline", start, end);

        text.buffer.get_iter_at_line_index(out start, 2, 76);
        text.buffer.get_iter_at_line_index(out end, 2, 107);
        text.buffer.apply_tag_by_name("em", start, end);
    }
}
