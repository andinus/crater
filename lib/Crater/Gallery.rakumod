class Crater::Gallery {
    has IO $.directory is required;
    has Str $!title;

    submethod TWEAK() {
        # Get title from file if exists.
        my $title-file = $!directory.add(".crater/title");
        $!title = $title-file.slurp.chomp if $title-file.f;
    }

    #| Accessor for $!title.
    method title() { $!title }

    method list(:@sub-dir) {
        # This will be considered an attempt to attack. There is no
        # reason to check '.' I belive.
        die "[!!!] @sub-dir contains '..'/'.'" if @sub-dir.grep('.'|'..');

        # Serve the subdirectory if passed.
        my @paths = @sub-dir
                     ?? $!directory.add(@sub-dir.join("/")).dir
                     !! $!directory.dir;

        # Gallery holds all the elements that will be shown.
        my @gallery;
        @gallery.push(%( :type<heading>, :text($_) )) with $!title;

        # Add directories on top.
        for @paths.grep(*.d).sort {
            next if .ends-with(".crater");
            push @gallery, %(:type<directory>, :text($_.relative($!directory)));
        }

        # Adding supported file types.
        for @paths.grep(*.f).sort(*.modified) -> $f {
            my $rel = $f.relative($!directory);

            given $f.extension.lc {
                when 'jpg'|'png' {
                    my $thumb = $!directory.add(".crater/thumbnails").add($rel);

                    # For images get the original if thumbnail doesn't
                    # exist, otherwise use the thumbnail.
                    push @gallery, %(
                        :type<img>,
                        :src($thumb.f ?? $rel !! "{$rel}?original"),
                        alt => $rel
                    );
                }
                when '0' {
                    push @gallery, %(:type<heading>, :text($f.slurp.chomp));
                }
                when 'txt' {
                    push @gallery, %(:type<text>, :text($f.slurp.chomp));
                }
                default {
                    note "Unhandled file: $f";
                }
            }
        }
        return @gallery;
    }
}
