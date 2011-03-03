using Clutter;
using Gtk;
using GtkClutter;

using Editor;

public class EditorApp : GLib.Object {
    Gtk.Window window;
    // EditorTextView text;

    public static int main(string[] args) {
        // Totally a hack. Vala is weird.
        string[] args_ = args;
        GtkClutter.init(ref args_);

        EditorApp app = new EditorApp();
        app.show();

        Gtk.main();

        return 0;
    }

    public EditorApp() {
        window = new Gtk.Window();
        window.destroy.connect(() => {
            Gtk.main_quit();
        });

        window.add(new EditorTextView());
    }

    public void show() {
        window.show_all();
    }
}
