require 'haml'

class Racker
  def call(env)
    @request = Rack::Request.new(env)
    response(env)
  end

  def response(env)
    case @request.path
    when '/' then Rack::Response.new(render('menu'))
    when '/registration'
        @request.session {||}
       .redirect('game')
    when '/game' then Rack::Response.new(render('game'))
    when '/statistics' then Rack::Response.new(render('statistics'))
    when '/win' then Rack::Response.new(render('win'))
    when '/lose' then Rack::Response.new(render('lose'))
    else Rack::Response.new('Not Found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}.html.haml", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end

  # def word
  #   @request.cookies['word'] || 'Nothing'
  # end
end
