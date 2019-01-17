require 'spec_helper'

describe CodebreakerWebAdapter do
  let(:app) { Rack::Builder.parse_file('config.ru').first }

  describe "when welcome" do
    before do
      visit '/'
    end

    scenario 'returns the status 200' do
      expect(status_code).to be(200)
    end
    scenario "home page" do
      expect(page).to have_content I18n.t(:codebreaker_title)
    end
  end

  let(:game) { CodebreakerRostik::Game.new }
  let(:user_name) { 'Rostik' }
  let(:test_difficulty) { CodebreakerRostik::Difficulty::DIFFICULTIES[:easy][:difficulty].downcase }
  let(:session) {Capybara::Session.new(:culerity, MyRackApp)}

  describe 'when show rules' do
    let(:response) { get '/rules' }

    it 'show rules' do
      expect(response).to be_ok
      expect(response.body).to include I18n.t(:game_rules)
    end
  end

  describe 'when show statistics' do
    let(:response) { get '/statistics' }

    it 'show statistics' do
      expect(response).to be_ok
      expect(response.body).to include I18n.t(:top_players)
    end
  end

  describe 'when 404 error' do
    let(:error_url) { '/anything' }
    let(:response) { get error_url }

    it { expect(response.body).to include I18n.t(:not_found_page) }
  end

  describe 'when user registrate' do
    let(:response) do
      post '/registration', player_name: user_name, level: test_difficulty
    end

    before do
      response
      follow_redirect!
    end

    it 'registrate' do
      expect(last_request.session[:name]).to eq user_name
      expect(last_request.session[:level]).to eq test_difficulty
      expect(response).to be_redirect
      expect(last_response).to be_ok
      expect(last_response.body).to include I18n.t(:hello, name: user_name)
    end
  end

  context 'when show hint' do
    let(:response) { post '/show_hint' }
    let(:response_registration) do
      post '/registration',
           player_name: user_name,
           level: test_difficulty
    end

    describe 'show hint' do
      before do
        response_registration
        response
        follow_redirect!
      end

      it 'show hint' do
        expect(response).to be_redirect
      end
    end
  end

  describe 'when user win' do
    let(:secret_code) { [1, 1, 1, 1] }
    let(:valid_code) { '1111' }
    let(:path_to_test_db) { './lib/db/db.yaml' }
    let(:response_registration) do
      post '/registration',
           player_name: user_name,
           level: test_difficulty
    end
    let(:response) { post '/play_game', guess_code: valid_code }

    before do
      response_registration
      env 'rack.session', game: game
      game.instance_variable_set(:@secret_code, secret_code)
      response
      follow_redirect!
    end

    after { File.delete(path_to_test_db) }

    it 'win' do
      expect(response).to be_redirect
      expect(last_response).to be_ok
      expect(last_response.body).to include I18n.t(:user_win, name: user_name)
    end
  end

  describe 'when user lose' do
    let(:secret_code) { [1, 1, 1, 1] }
    let(:invalid_code) { '2222' }
    let(:response_registration) do
      post '/registration',
           player_name: user_name,
           level: test_difficulty
    end
    let(:response) { post '/play_game', guess_code: invalid_code }

    before do
      response_registration
      env 'rack.session', game: game
      game.instance_variable_set(:@secret_code, secret_code)
      game.instance_variable_set(:@attempts_left, 14)
      response
      follow_redirect!
    end

    it 'lose' do
      expect(last_response).to be_ok
      expect(response).to be_redirect
      expect(last_response.body).to include I18n.t(:lose, name: user_name)
    end
  end
end
