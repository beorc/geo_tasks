# frozen_string_literal: true
module Sinatra
  module Authentication
    def current_user
      @current_user
    end

    def authenticated?
      request.env['REMOTE_USER']
    end

    def authenticate!(token)
      return if authenticated?
      unauthorized!(body: 'Authorization Required') if token.empty?
      @current_user = User.where(token: token).first
      unauthorized!(body: 'Bad credentials') unless @current_user
      request.env['REMOTE_USER'] = @current_user.name
    end

    private

    def unauthorized!(body:, realm: 'geo tasks')
      response['WWW-Authenticate'] = %(Token realm="#{realm}")
      throw :halt, [401, body]
    end
  end

  helpers Authentication
end
