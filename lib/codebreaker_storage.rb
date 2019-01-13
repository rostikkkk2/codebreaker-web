# frozen_string_literal: true

class CodebreakerStorage
  def initialize(request)
    @request = request
    @storage ||= CodebreakerRostik::Storage.new
  end

  def save
    user = {
      name: @request.session[:name],
      level: @request.session[:level],
      attempts_left: "#{@request.session[:attempts_left] || 0} / #{@request.session[:attempts_total]}",
      hints_left: "#{@request.session[:hints_left] || 0} / #{@request.session[:hints_total]}",
      date: Time.now
    }
    @storage.add_data_to_db(user)
  end
end
