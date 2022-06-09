class Crater::Gallery {
    has IO $.directory is required;

    method list() {
        my @gallery;
        for dir($!directory).sort(*.modified) {
            if .IO.d {

            } elsif .IO.f {
                my Str $ext = .extension.lc;
                if $ext eq "jpg"|"png" {
                    push @gallery, %( :type<img>, :src($_.relative($!directory)) );
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
