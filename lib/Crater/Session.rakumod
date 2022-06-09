use Cro::HTTP::Auth;

class Crater::Session does Cro::HTTP::Auth {
    has Bool $.logged-in is rw;
}

subset LoggedIn of Crater::Session is export where *.logged-in;
