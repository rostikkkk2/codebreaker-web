# frozen_string_literal: true

module CodebreakerHelpers
  URLS = {
    home: '/',
    rules: '/rules',
    registration: '/registration',
    game: '/game',
    statistics: '/statistics',
    show_hint: '/show_hint',
    win: '/win',
    lose: '/lose',
    play_game: '/play_game'
  }.freeze
  RENDERS = {
    menu: 'menu',
    rules: 'rules',
    game: 'game',
    statistics: 'statistics',
    win: 'win',
    lose: 'lose'
  }.freeze
  NOT_FOUND_PAGE = 'not_found_page'

  def render(template)
    path = File.expand_path("../../views/#{template}.html.haml", __FILE__)
    Haml::Engine.new(File.read(path)).render(binding)
  end

  def render_page(page)
    Rack::Response.new(render(page))
  end

  def redirect(page)
    Rack::Response.new { |response| response.redirect(page) }
  end

  def clear_session_if_game_over
    clear_session if @request.session[:game_over_win] || @request.session[:game_over_lose]
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
