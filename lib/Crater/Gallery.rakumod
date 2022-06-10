class Crater::Gallery {
    has IO $.directory is required;

    method list() {
        my @gallery;
        for $!directory.dir.sort(*.modified) {
            if .IO.d {

            } elsif .IO.f {
                my Str $ext = .extension.lc;
                if $ext eq "jpg"|"png" {
                    push @gallery, %(
                        :type<img>, :src($_.relative($!directory)),
                        :alt($_)
                    );
                } elsif $ext eq "0" {
                    push @gallery, %( :type<heading>, :text($_.slurp) );
                } elsif $ext eq "txt" {
                    push @gallery, %( :type<text>, :text($_.slurp) );
                } else {
                    warn "Unhandled file :$_";
                }
            }
        }
        return @gallery;
    }
}
