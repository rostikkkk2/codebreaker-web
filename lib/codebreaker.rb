class Codebreaker
  include CodebreakerHelpers

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session[:game] ||= CodebreakerRostik::Game.new
  end

  def response
    @game = CodebreakerGame.new(@request)
    case @request.path
    when URLS[:home] then menu
    when URLS[:rules] then show_rules
    when URLS[:registration] then registration
    when URLS[:game] then @game.game
    when URLS[:statistics] then show_statistics
    when URLS[:show_hint] then @game.show_hint
    when URLS[:win] then @game.win
    when URLS[:lose] then @game.lose
    when URLS[:play_game] then @game.play_game
    else not_found
    end
  end

  def registration
    @request.session[:name] ||= @request.params['player_name']
    @request.session[:level] ||= @request.params['level']
    set_difficulty
    redirect(URLS[:game])
  end

  def set_difficulty
    difficulties = CodebreakerRostik::Difficulty::DIFFICULTIES[@request.params['level'].to_sym]
    @request.session[:hints_total] ||= difficulties[:hints_total]
    @request.session[:attempts_total] ||= difficulties[:attempts_total]
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
    if !session_present? || @request.session[:game_over_lose] || @request.session[:game_over_win]
      return render_page(RENDERS[:statistics])
    end
    redirect(URLS[:game])
  end

  def not_found
    render_page(NOT_FOUND_PAGE)
  end

end
