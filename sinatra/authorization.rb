# frozen_string_literal: true
module Sinatra
  module Authorization
    def authorize_task_create!(user)
      'manager' == user.role || forbidden!
    end

    private

    def forbidden!
      throw :halt, [403, 'Forbidden']
    end
  end

  helpers Authorization
end
