use Cro::HTTP::Router;
use Cro::WebApp::Template;

use Crater::Gallery;
use Crater::Session;

sub gallery-routes(
    Crater::Gallery :$gallery!, #= gallery object
) is export {
    route {
        # Logged in users can view images.
        get -> LoggedIn $session, 'resources', 'img', *@path, :$original {
            my $dir = $gallery.directory;
            # Serve the thumbnail unless original image was requested.
            $dir .= add(".crater/thumbnails") unless $original.defined;
            static $dir, @path;
        }

        # Gallery view.
        get -> LoggedIn $session, *@path {
            # Generates a navigation bar for nested directories.
            my @nav = %(name => "home", url => "/"), ;
            for @path.kv -> $idx, $p {
                next if $p eq "";
                push @nav, %(
                    name => $p,
                    url => (@nav[*-1]<url> ~ $p ~ "/")
                );
            }

            template 'gallery.crotmp', {
                gallery => $gallery.list(sub-dir => @path),
                title => $gallery.title(),
                nav => @nav,
                show-nav => @path.elems ?? True !! False
            };
        }

        # Redirect to login page if not logged in.
        get -> *@path {
            redirect '/login', :see-other;
        }
    }
}
