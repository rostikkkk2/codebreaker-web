class CodebreakerGame
  include CodebreakerHelpers

  def initialize(request)
    @request = request
  end

  def game
    clear_session_if_game_over
    return render_page(RENDERS[:game]) if session_present?
    redirect(URLS[:home])
  end

  def play_game
    p @request.session[:secret_code] = @request.session[:game].secret_code
    guess_code = @request.params['guess_code']
    @request.session[:signs] = @request.session[:game].compare_guess_and_secret_codes(guess_code)
    check_win_with_lose
  end

  def check_win_with_lose
    return check_lose if @request.session[:secret_code].join != @request.params['guess_code']
    @request.session[:game_over_win] = true
    redirect(URLS[:win])
  end

  def win
    return redirect(URLS[:home]) unless @request.session[:game_over_win]
    CodebreakerStorage.new(@request).save
    render_page(RENDERS[:win])
  end

  def show_hint
    @request.session[:secret_code_hints] = @request.session[:game].secret_code_for_hints
    @request.session[:game].hints_left_increment
    @request.session[:hints_left] = @request.session[:game].hints_left
    redirect(URLS[:game])
  end

  def lose
    return redirect(URLS[:home]) unless @request.session[:game_over_lose]
    render_page(RENDERS[:lose])
  end

  def increment_attempts
    @request.session[:game].attempts_left_increment
    @request.session[:attempts_left] = @request.session[:game].attempts_left
  end

  def check_lose
    increment_attempts
    return redirect(URLS[:game]) if @request.session[:attempts_left] != @request.session[:attempts_total]
    @request.session[:game_over_lose] = true
    redirect(URLS[:lose])
  end

end
