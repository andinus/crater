use Cro::HTTP::Router;
use Cro::WebApp::Template;

use Crater::Gallery;
use Crater::Routes::Auth;
use Crater::Routes::Gallery;

sub routes(
    Crater::Gallery :$gallery!, #= gallery object
    Str :$password!, #= password for authentication
) is export {
    template-location 'templates/';

    route {
        after { redirect '/login', :see-other if .status == 401 };

        include auth-routes(:$password);
        include gallery-routes(:$gallery);

        get -> 'resources', 'css', *@path {
            static 'resources', 'css', @path;
        }
        get -> 'resources', 'js', *@path {
            static 'resources', 'js', @path;
        }
    }
}
