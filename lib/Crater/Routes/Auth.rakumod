use Cro::HTTP::Router;
use Cro::WebApp::Template;

use Crater::Session;

sub auth-routes(
    Str :$password!, #= password for authentication
) is export {
    route {
        get -> LoggedIn $session, 'login' {
            redirect '/', :see-other;
        }
        get -> Crater::Session $session, 'login' {
            template 'login.crotmp', { :!error };
        }
        post -> Crater::Session $session, 'login' {
            request-body -> (:$pass!, *%) {
                if $password eq $pass {
                    $session.logged-in = True;
                    redirect :see-other, '/';
                } else {
                    template 'login.crotmp', {
                        error => 'Incorrect password.'
                    };
                }
            }
        }
        get -> LoggedIn $session, 'logout' {
            $session.logged-in = False;
            redirect :see-other, '/';
        }
    }
}
