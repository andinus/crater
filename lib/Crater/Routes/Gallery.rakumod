use Cro::HTTP::Router;
use Cro::WebApp::Template;

use Crater::Gallery;
use Crater::Session;

sub gallery-routes(
    Crater::Gallery :$gallery!, #= gallery object
) is export {
    route {
        get -> LoggedIn $session {
            template 'gallery.crotmp', {
                gallery => $gallery.list(),
                title => "Gallery"
            };
        }

        get -> {
            redirect '/login', :see-other;
        }
        get -> *@path {
            static $gallery.directory.add(".crater/thumbnails"), @path;
        }
    }
}
