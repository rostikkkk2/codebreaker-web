require 'spec_helper'

describe CodebreakerWebAdapter do

  describe "when welcome" do
    before { visit '/' }

    scenario 'returns the status 200' do
      expect(status_code).to be(200)
    end
    scenario "home page" do
      expect(page).to have_content I18n.t(:codebreaker_title)
    end
  end
end
