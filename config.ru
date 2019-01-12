require_relative 'autoload'
require './lib/codebreaker'

use Rack::Reloader
use Rack::Static, urls: ['/assets', '/node_modules'], root: './'
use Rack::Session::Cookie, key: 'rack.session', secret: 'change_me'
run Codebreaker
