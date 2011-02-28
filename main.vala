using Clutter;

using Editor;

public class EditorApp : GLib.Object {
    Stage stage;
    Text text;

    public static int main(string[] args) {
        Clutter.init(ref args);

        EditorApp app = new EditorApp();
        app.show();

        Clutter.main();

        return 0;
    }

    construct {
        stage = Stage.get_default();
        stage.width = 1000;
        stage.height = 850;
        // stage.set_fullscreen(true);

        stage.hide.connect(Clutter.main_quit);

        // Setup container box
        var layout = new BoxLayout();
        var box = new Box(layout);
        box.width = stage.width;
        box.height = stage.height;
        stage.add(box);

        // Setup text
        var textContainer = new Box(new FixedLayout());
        text = new TextView();
        text.width = stage.width - 250;
        text.height = stage.height;
        text.set_position(30, 30);

        textContainer.pack(text);
        box.pack(textContainer);

        // Add rect
        var rect = new Rectangle.with_color(Color.from_string("pink"));
        rect.width = 250;
        rect.height = stage.height;
        box.pack(rect);
    }

    public void show() {
        stage.show_all();
        stage.ensure_viewport();
    }
}
