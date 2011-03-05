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
        private TextLayout text_layout;
        private bool has_focus;
        private BindingPool pool;

        public TextView() {
            has_focus = false;
            reactive = true;

            TextTagTable tagtable = new TextTagTable();
            buffer = new TextBuffer(tagtable);

            text_layout = new TextLayout(buffer);

            // Insert bindings
            pool = BindingPool.get_for_class(this.get_class());
            pool.install_action("delete-prev", 0xff08, 0,
                    (obj, action, keyval, modifiers) => {
                // Can't just pass delete_previous for some reason. Vala bug?
                return delete_previous(action, keyval, modifiers);
            });
            pool.install_action("delete-prev", 0xff08, ModifierType.CONTROL_MASK,
                    (obj, action, keyval, modifiers) => {
                // Can't just pass delete_previous for some reason. Vala bug?
                return delete_previous(action, keyval, modifiers);
            });

            // Connect events
            button_press_event.connect(button_press);
            motion_event.connect(motion);
            button_release_event.connect(button_release);
            key_press_event.connect(key_press);
            key_release_event.connect(key_release);

            key_focus_in.connect(() => {
                has_focus = true;
                queue_redraw();
            });
            key_focus_out.connect(() => {
                has_focus = false;
                queue_redraw();
            });
        }

        public void insert_text(string text) {
            buffer.insert_at_cursor(text, -1);
            update_layout_text();
        }

        public void insert_unichar(unichar c) {
            if (c != 0) {
                buffer.insert_at_cursor(c.to_string(), 1);
                update_layout_text();
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
                    // Select paragraphs
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
            if (pool.activate(e.keyval, e.modifier_state, this)) {
                return true;
            }

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

        private bool delete_previous(string action, uint keyval, ModifierType modifiers) {
            if ((modifiers & ModifierType.CONTROL_MASK) != 0) {
                // Control held, delete previous word
                TextIter insertIter, wordStart;
                buffer.get_iter_at_mark(out insertIter, buffer.get_insert());
                wordStart = insertIter;
                wordStart.backward_word_start();

                buffer.delete(insertIter, wordStart);
            } else {
                TextIter insertIter;
                buffer.get_iter_at_mark(out insertIter, buffer.get_insert());

                buffer.backspace(insertIter, true, true);
            }
            update_layout_text();
            return true;
        }

        private void update_layout_text() {
            TextIter start, end;
            buffer.get_start_iter(out start);
            buffer.get_end_iter(out end);

            // get_layout() might not know its size before rendering.
            get_layout().set_text(buffer.get_text(start, end, true), -1);
            queue_redraw();
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
