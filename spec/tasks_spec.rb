require 'spec_helper.rb'

describe 'Tasks' do
  let(:user) { Factory.create!(:user, role: 'manager') }
  let(:token) { user.token }
  let(:headers) do
    {
      'HTTP_AUTHORIZATION' => 'Bearer ' + token,
      'HTTPS' => 'on'
    }
  end

  describe 'POST /tasks' do
    let(:params) do
      {
        pickup_point: { lat: 44.106667, lng: -73.935833 },
        delivery_point: { lat: 44.106668, lng: -73.935834 }
      }
    end
    let(:request_block) do
      -> { post '/tasks', params.to_json, headers }
    end

    context 'given valid token' do
      context 'given user having role manager' do
        context 'given valid params' do
          it 'creates a task' do
            request_block.call

            expect(last_response.status).to eq 201
            expect(json_body['state']).to eq('available')
            expect(json_body['pickup_point']).to eq([-73.935833, 44.106667])
            expect(json_body['delivery_point']).to eq([-73.935834, 44.106668])
          end
        end

        context 'given invalid params' do
          let(:params) do
            {
              pickup_point: { lat: 44.106667, lng: -73.935833 }
            }
          end

          it 'does not create task and renders validation errors' do
            request_block.call

            expect(last_response.status).to eq 422
            expect(json_body['errors']).to eq('delivery_point' => 'can\'t be blank')
          end
        end
      end

      context 'without token' do
        let(:headers) { {} }

        it 'does not create a task' do
          request_block.call

          expect(last_response.status).to eq 401
          expect(last_response.body).to eq 'Authorization Required'
        end
      end

      context 'given a not existing token' do
        let(:token) { 'invalid' }

        it 'does not create a task' do
          request_block.call

          expect(last_response.status).to eq 401
          expect(last_response.body).to eq 'Bad credentials'
        end
      end

      context 'given a driver token' do
        let(:user) { Factory.create!(:user, role: 'driver') }

        it 'does not create a task' do
          request_block.call

          expect(last_response.status).to eq 403
          expect(last_response.body).to eq 'Forbidden'
        end
      end
    end
  end
end
