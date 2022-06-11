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
            template 'gallery.crotmp', {
                gallery => $gallery.list(sub-dir => @path),
                title => "Gallery"
            };
        }

        # Redirect to login page if not logged in.
        get -> *@path {
            redirect '/login', :see-other;
        }
    }
}
