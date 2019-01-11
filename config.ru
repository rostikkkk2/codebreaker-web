require './lib/racker'

use Rack::Reloader
use Rack::Static, urls: ['/assets', '/node_modules'], root: './'
use Rack::Session::Cookie, key: 'rack.session', secret: 'change_me'
run Racker
