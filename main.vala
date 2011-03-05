using Clutter;

using Editor;

public class EditorApp : GLib.Object {
    Stage stage;
    TextView text;

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
        text.height = stage.height - 60;
        text.width = stage.width - 250;
        text.set_position(30, 30);

        textContainer.pack(text);
        box.pack(textContainer);

        // Add rect
        var rect = new Rectangle.with_color(Color.from_string("pink"));
        rect.width = 250;
        rect.height = stage.height;
        box.pack(rect);

        // Add default text
        text.insert_text("Quisque dapibus commodo arcu nec tristique. Sed at nulla id neque ornare scelerisque nec non purus. Curabitur consectetur pharetra sapien ut porttitor. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec aliquet sollicitudin tellus, sagittis tempor nibh eleifend id. Suspendisse potenti. Aliquam laoreet nisi mattis lacus hendrerit eget varius tortor mollis. Sed bibendum, ipsum eu tempor gravida, neque erat malesuada nunc, vitae elementum nibh erat nec eros. Nullam sed nisi libero, quis hendrerit dui. Vivamus semper tortor id risus egestas porta. Pellentesque porta scelerisque ultricies. Nunc justo diam, luctus vitae tristique vel, condimentum vitae turpis. Pellentesque ac velit id orci lacinia placerat eget eget lorem.\nNunc auctor sollicitudin dui non pellentesque. Aliquam erat volutpat. Fusce vel velit a nisl condimentum mattis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vitae metus risus, vitae congue magna. Aliquam a purus odio, nec egestas mauris. Suspendisse potenti. Nulla quis ligula lorem. Vestibulum dolor tellus, vehicula at sollicitudin tempor, rutrum non enim. Phasellus vitae pulvinar justo.");
    }

    public void show() {
        stage.show_all();
        stage.ensure_viewport();
    }
}
