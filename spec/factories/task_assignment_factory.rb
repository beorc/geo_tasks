# frozen_string_literal: true
module Cranky
  class Factory
    def task_assignment
      define(
        task: build(:task, state: 'assigned'),
        user: build(:user)
      )
    end
  end
end
