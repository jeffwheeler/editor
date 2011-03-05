using Clutter;
using Cogl;
using Gtk;
using Pango;

/* This widget uses GtkTextView APIs (like GtkTextBuffer), but renders on its
   own. Basically, everything is the same, but the GtkTextView is replaced with
   this. */
namespace Editor {
    class TextView : Actor {
        private TextBuffer buffer;
        private Pango.Layout layout;
        private bool has_focus;
        private BindingPool pool;

        public TextView() {
            has_focus = false;
            reactive = true;

            TextTagTable tagtable = new TextTagTable();
            buffer = new TextBuffer(tagtable);

            // Insert bindings
            pool = BindingPool.get_for_class(this.get_class());

            // Connect events
            button_press_event.connect(button_press);
            motion_event.connect(motion);
            button_release_event.connect(button_release);
            key_press_event.connect(key_press);
            key_release_event.connect(key_release);

            key_focus_in.connect(() => {
                // print("getting focus\n");
                has_focus = true;
                queue_redraw();
            });
            key_focus_out.connect(() => {
                // print("losing focus\n");
                has_focus = false;
                queue_redraw();
            });
        }

        public override void get_preferred_width(float for_height, out float min_width_p, out float natural_width_p) {
            min_width_p = 300;
            natural_width_p = 300;
        }

        public override void get_preferred_height(float for_width, out float min_height_p, out float natural_height_p) {
            min_height_p = 300;
            natural_height_p = 500;
        }

        public void insert_text(string text) {
            buffer.insert_at_cursor(text, -1);

            TextIter start, end;
            buffer.get_start_iter(out start);
            buffer.get_end_iter(out end);

            get_layout().set_text(buffer.get_text(start, end, true), -1);
            queue_redraw();
        }

        public void insert_unichar(unichar c) {
            if (c != 0) {
                buffer.insert_at_cursor(c.to_string(), 1);

                TextIter start, end;
                buffer.get_start_iter(out start);
                buffer.get_end_iter(out end);

                get_layout().set_text(buffer.get_text(start, end, true), -1);
                queue_redraw();
            }
        }

        public override void paint() {
            ActorBox actor_box;
            float width, height;
            get_allocation_box(out actor_box);
            actor_box.get_size(out width, out height);

            // Draw background behind the text
            Cogl.set_source_color4ub(220, 220, 220, get_paint_opacity());
            Cogl.Path.rectangle(0, 0, width, height);
            Cogl.Path.fill();

            // Draw text
            var layout = get_layout();
            Cogl.Color c = {};
            c.init_from_4ub(0, 0, 0, get_paint_opacity());
            Cogl.pango_render_layout(layout, 0, 0, c, 0);

            // Draw cursor
            if (has_focus) {
                paint_cursor(layout);
            }
        }

        private void paint_cursor(Pango.Layout layout) {
            // Can probably cache 'insert' position. Worthwhile?
            TextIter insertIter;
            buffer.get_iter_at_mark(out insertIter, buffer.get_insert());

            int offset = insertIter.get_offset();
            Pango.Rectangle rect, rect_;
            layout.get_cursor_pos(offset, out rect, null);
            rect_ = rect;

            extents_to_pixels(ref rect, ref rect_);

            // This needs to be refined. How does ClutterText do it?
            Cogl.set_source_color4ub(80, 121, 158, get_paint_opacity()*7/10);
            Cogl.Path.rectangle(rect.x, rect.y, rect.x + rect.width + 1, rect.y + rect.height);
            Cogl.Path.fill();
        }

        private bool button_press(ButtonEvent e) {
            grab_key_focus();

            float x, y;
            if (transform_stage_point(e.x, e.y, out x, out y)) {
                TextIter start, end;
                buffer.get_start_iter(out start);
                buffer.get_end_iter(out end);

                int offset = (int)coords_to_position(x, y);
                if (e.click_count == 1) {
                    // Move 'insert' mark
                    TextIter newCursor;
                    buffer.get_iter_at_offset(out newCursor, offset);
                    buffer.place_cursor(newCursor);
                } else if (e.click_count == 2) {
                    // Select words
                } else if (e.click_count == 3) {
                    // Select lines
                }
                queue_redraw();
            }

            grab_pointer(this);

            return true;
        }

        private bool motion() {
            return false;
        }

        private bool button_release() {
            return false;
        }

        private bool key_press(KeyEvent e) {
            // Look for registered keypresses in the pool first

            // Ignore keypresses when control was held
            if ((e.modifier_state & ModifierType.CONTROL_MASK) == 0) {
                unichar key = e.unicode_value;
                if (key.validate()) {
                    // stdout.printf("key: %s\n", key.to_string());
                    insert_unichar(key);
                }
            }
            return false;
        }

        private bool key_release() {
            return false;
        }

        private Pango.Layout create_layout(float width, float height) {
            TextIter start, end;
            buffer.get_start_iter(out start);
            buffer.get_end_iter(out end);

            // Construct layout
            var layout = create_pango_layout(buffer.get_text(start, end, true));

            // Set properties
            layout.set_alignment(Pango.Alignment.LEFT);
            layout.set_single_paragraph_mode(false);
            layout.set_justify(true);
            layout.set_wrap(Pango.WrapMode.WORD);

            layout.set_width((int)(SCALE*width));
            layout.set_height((int)(SCALE*height));

            layout.set_spacing(SCALE*5);

            // Set font attributes
            // AttrList attrs;

            // How do I fix paragraph spacing?

            return layout;
        }

        // Must be accessible from included file.
        public Pango.Layout get_layout() {
            float width, height;
            get_size(out width, out height);
            int pw = (int)(SCALE*width), ph = (int)(SCALE*height);
            if (layout == null || layout.get_width() != pw || layout.get_height() != ph) {
                print("Creating new layout\n");
                layout = create_layout(width, height);
            }
            return layout;
        }

        extern long coords_to_position(float x, float y);
    }
}
