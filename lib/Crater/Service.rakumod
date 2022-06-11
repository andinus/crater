use Config::TOML;

use Cro::HTTP::Server;
use Cro::HTTP::Log::File;
use Cro::HTTP::Session::InMemory;

use Crater::Routes;
use Crater::Gallery;
use Crater::Session;

#| Crater is a photo gallery.
sub MAIN(
    IO() :$config where *.IO.f = 'resources/config.toml', #= configuration file
    IO() :$directory! where *.IO.d, #= gallery directory (takes absolute path)
    Str :$password = '0x', #= password for authentication
    Bool :$verbose, #= increase verbosity
) is export {
    put "Initialized: {now - INIT now}";
    put "Gallery: {$directory.absolute}";
    put "Password: $password";

    my Crater::Gallery $gallery = Crater::Gallery.new(:$directory);

    my %conf = from-toml($config.slurp);
    my Cro::Service $http = Cro::HTTP::Server.new(
        http => <1.1>,
        allowed-methods => <GET POST>,
        host => %conf<server><host> || die("host not set"),
        port => %conf<server><port> || die("port not set"),
        application => routes(:$password, :$gallery),
        before => [
                   Cro::HTTP::Session::InMemory[Crater::Session].new(
                       expiration => Duration.new(60 * 15)
                   );
               ],
        after => [
                  Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
              ]
    );

    $http.start;
    say "Listening at http://%conf<server><host>:%conf<server><port>";

    react {
        whenever signal(SIGINT) {
            say "Shutting down...";
            $http.stop;
            done;
        }
    }
}
