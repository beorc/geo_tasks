# frozen_string_literal: true
module Cranky
  class Factory
    def user
      define(
        name: "name#{n}",
        token: User.generate_token,
        role: 'manager'
      )
    end
  end
end
