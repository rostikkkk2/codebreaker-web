require_relative '../autoload'

class Racker
  def call(env)
    @request = Rack::Request.new(env)
    response(env)
  end

  def response(env)
    case @request.path
    when '/' then menu
    when '/ragistration' then registration
    when '/game' then game
    when '/statistics' then show_statistics
    when '/win' then win
    when '/lose' then lose
    else not_found
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}.html.haml", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end

  def registration
    @request.session[:name] = @request.params['player_name']
    @request.session[:level] = @request.params['level']
    Rack::Response.new { |response| response.redirect('/game') }
  end

  def game
    return Rack::Response.new(render('game')) if session_present?
    Rack::Response.new { |response| response.redirect('/') }
  end

  def menu
    return Rack::Response.new(render('menu')) unless session_present?
    Rack::Response.new { |response| response.redirect('/game') }
  end

  def show_statistics
    Rack::Response.new(render('statistics'))
  end

  def lose
    clear_session
    Rack::Response.new(render('lose'))
  end

  def win
    clear_session
    Rack::Response.new(render('win'))
  end

  def not_found
    Rack::Response.new('Not Found', 404)
  end

  def show_info(message)
    I18n.t(message)
  end

  def clear_session
    @request.session.clear
  end

   def session_present?
     @request.session.key?(:name)
   end
end
