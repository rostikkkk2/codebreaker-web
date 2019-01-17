# frozen_string_literal: true

class WebInterface
  include CodebreakerHelpers

  attr_reader :game, :request

  ROUTES = {
    URLS[:home] => ->(interface) { interface.menu },
    URLS[:rules] => ->(interface) { interface.show_rules },
    URLS[:registration] => ->(interface) { interface.registration },
    URLS[:game] => ->(interface) { interface.game.play },
    URLS[:statistics] => ->(interface) { interface.show_statistics },
    URLS[:show_hint] => ->(interface) { interface.game.show_hint },
    URLS[:win] => ->(interface) { interface.game.win },
    URLS[:lose] => ->(interface) { interface.game.lose },
    URLS[:play_game] => ->(interface) { interface.game.play_game },
  }.freeze

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    request.session[:game] ||= CodebreakerRostik::Game.new
  end

  def response
    @game ||= CodebreakerWebAdapter.new(request)
    ROUTES.key?(request.path) ? ROUTES[request.path].call(self) : not_found
  end

  def registration
    request.session[:name] ||= request.params['player_name']
    request.session[:level] ||= request.params['level']
    set_difficulty
    redirect(URLS[:game])
  end

  def set_difficulty
    return redirect(URLS[:home]) unless request.session[:name]

    difficulties = CodebreakerRostik::Difficulty::DIFFICULTIES[request.params['level'].to_sym]
    request.session[:hints_total] ||= difficulties[:hints_total]
    request.session[:attempts_total] ||= difficulties[:attempts_total]
  end

  def show_rules
    return render_page(RENDERS[:rules]) unless session_present?

    redirect(URLS[:game])
  end

  def menu
    clear_session_if_game_over
    return render_page(RENDERS[:menu]) unless session_present?

    redirect(URLS[:game])
  end

  def show_statistics
    if !session_present? || request.session[:game_over_lose] || request.session[:game_over_win]
      return render_page(RENDERS[:statistics])
    end

    redirect(URLS[:game])
  end

  def not_found
    render_page(NOT_FOUND_PAGE)
  end
end
