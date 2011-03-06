using Gee;
using Gtk;

namespace Editor {
    class TextEditor : TextView {
        public TextTag default_style { get; set; }
        private HashSet<TextTag> pstyles;

        // Contains the pstyles which should continue when the user presses
        // enter. E.g. "body" can continue just fine, but it would be weird
        // for "h1" to continue onto the next line.
        private HashSet<TextTag> running_pstyles;

        public TextEditor() {
            wrap_mode = WrapMode.WORD_CHAR;
            // buffer.changed.connect(reformat_paragraphs);

            // Add default tags to tag table
            pstyles = new HashSet<TextTag>();
            running_pstyles = new HashSet<TextTag>();

            var h1 = new TextTag("h1");
            h1.font = "Arial Black";
            h1.pixels_above_lines = 6;
            h1.pixels_below_lines = 9;
            h1.size = 25 * Pango.SCALE;

            var h2 = new TextTag("h2");
            h2.font = "Arial Black";
            h2.pixels_above_lines = 4;
            h2.pixels_below_lines = 7;
            h2.foreground = "#444";
            h2.size = 20 * Pango.SCALE;

            var body = new TextTag("body");
            body.font = "Georgia";
            body.pixels_above_lines = 4;
            body.pixels_below_lines = 6;

            var quote = new TextTag("quote");
            quote.background = "#ccc";
            quote.font = "Georgia";
            quote.pixels_below_lines = 10;
            quote.pixels_above_lines = 10;
            quote.left_margin = 10;
            quote.right_margin = 10;

            var strong = new TextTag("strong");
            strong.background = "#ffcc66";

            var em = new TextTag("em");
            em.style = Pango.Style.ITALIC;

            var underline = new TextTag("underline");
            underline.underline = Pango.Underline.SINGLE;

            buffer.tag_table.add(h1);
            buffer.tag_table.add(h2);
            buffer.tag_table.add(body);
            buffer.tag_table.add(quote);
            buffer.tag_table.add(strong);
            buffer.tag_table.add(em);
            buffer.tag_table.add(underline);

            pstyles.add(h1);
            pstyles.add(h2);
            pstyles.add(body);
            pstyles.add(quote);

            running_pstyles.add(body);
            running_pstyles.add(quote);

            default_style = body;

            buffer.end_user_action.connect_after(() => {
                TextIter insert;
                buffer.get_iter_at_mark(out insert, buffer.get_insert());
                reformat_paragraph(insert);
            });
        }

        public void reformat_paragraph(TextIter iter) {
            iter.set_line_offset(0);

            bool found_pstyle = false;
            foreach (TextTag pstyle in pstyles) {
                if (iter.begins_tag(pstyle) ||
                        (running_pstyles.contains(pstyle) && iter.has_tag(pstyle))) {
                    found_pstyle = true;
                    ensure_tag_ends_paragraph(iter, pstyle);
                    break;
                }
            }

            if (!found_pstyle) {
                TextIter end_prev_line = iter;

                // This is really bad. It doesn't work in general.
                end_prev_line.backward_line();
                end_prev_line.forward_to_line_end();
                end_prev_line.backward_char();

                bool applied_style = false;
                foreach (TextTag t in running_pstyles) {
                    if (end_prev_line.has_tag(t)) {
                        TextIter end = iter;
                        end.forward_line();

                        buffer.remove_all_tags(iter, end);
                        buffer.apply_tag(t, iter, end);

                        applied_style = true;
                    }
                }
                if (!applied_style) {
                    TextIter end = iter;
                    end.forward_line();

                    buffer.remove_all_tags(iter, end);
                    buffer.apply_tag(default_style, iter, end);
                }
            }
        }

        private void ensure_tag_ends_paragraph(TextIter iter, TextTag tag) {
            TextIter start_line = iter, end_line = iter;
            start_line.set_line_index(0);
            end_line.forward_line();

            buffer.apply_tag(tag, start_line, end_line);
        }
    }
}
