class Crater::Gallery {
    has IO $.directory is required;
    has Str $!title;

    submethod TWEAK() {
        my $title-file = $!directory.add(".crater/title");
        $!title = $title-file.slurp.chomp if $title-file.f;
    }

    #| Accessor for $!title.
    method title() { $!title }

    method list(:@sub-dir) {
        # This will be considered an attempt to attack. There is no
        # reason to check '.' I belive.
        if @sub-dir.grep('.'|'..').elems {
            die "[!!!] @sub-dir contains '..'/'.'";
        }

        my @gallery;
        my @paths = @sub-dir
                     ?? $!directory.add(@sub-dir.join("/")).dir
                     !! $!directory.dir;

        with $!title {
            push @gallery, %( :type<heading>, :text($_) );
        }

        # Add directories on top.
        for @paths.grep(*.d).sort {
            next if .ends-with(".crater");
            push @gallery, %( :type<directory>,
                              :text($_.relative($!directory)) );
        }

        for @paths.grep(*.f).sort(*.modified) {
            my Str $ext = .extension.lc;
            # For images get the original if thumbnail doesn't exist,
            # otherwise use the thumbnail.
            if $ext eq "jpg"|"png" {
                my $rel = $_.relative($!directory);
                my $alt = $rel;
                unless $!directory.add(".crater/thumbnails").add($rel).f {
                    $rel ~= "?original";
                }
                push @gallery, %( :type<img>, :src($rel), :$alt );
            } elsif $ext eq "0" {
                push @gallery, %( :type<heading>, :text($_.slurp.chomp) );
            } elsif $ext eq "txt" {
                push @gallery, %( :type<text>, :text($_.slurp.chomp) );
            } else {
                note "Unhandled file: $_";
            }
        }
        return @gallery;
    }
}
