require_relative '../autoload'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session[:game] ||= CodebreakerRostik::Game.new
  end

  def response
    case @request.path
    when '/' then menu
    when '/rules' then show_rules
    when '/ragistration' then registration
    when '/game' then game
    when '/statistics' then show_statistics
    when '/show_hint' then show_hint
    when '/win' then win
    when '/lose' then lose
    else not_found
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}.html.haml", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end

  def show_hint
    @request.session[:secret_code_hints] = @request.session[:game].secret_code_for_hints
    @request.session[:game].hints_left_increment

    # p @request.session[:hints] = array.push(@request.session[:game].give_digit_hint)
    # p array.push(@request.session[:game].give_digit_hint)
    p @request.session[:hints_left] = @request.session[:game].hints_left
    Rack::Response.new { |response| response.redirect('/game') }
  end

  def registration
    @request.session[:secret_code] = @request.session[:game].secret_code
    @request.session[:name] = @request.params['player_name']
    @request.session[:level] = @request.params['level']
    difficulties = CodebreakerRostik::Difficulty::DIFFICULTIES[@request.params['level'].to_sym]
    @request.session[:hints_total] = difficulties[:hints_total]
    Rack::Response.new { |response| response.redirect('/game') }
  end

  def show_rules
    Rack::Response.new(render('rules')) unless session_present?
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
    Rack::Response.new(render('statistics')) unless session_present?
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
    Rack::Response.new(render('not_found_page'))
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
