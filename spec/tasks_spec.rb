# frozen_string_literal: true
require 'spec_helper.rb'

shared_examples 'authentication required' do |parameter|
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
end

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

      context 'given a driver token' do
        let(:user) { Factory.create!(:user, role: 'driver') }

        it 'does not create a task' do
          request_block.call

          expect(last_response.status).to eq 403
          expect(last_response.body).to eq 'Forbidden'
        end
      end

      include_examples 'authentication required'
    end
  end

  describe 'GET /tasks' do
    let(:params) do
      { lat: 44.106666, lng: -73.935832 }
    end

    let(:request_block) do
      -> { get '/tasks', params, headers }
    end

    context 'given a valid token' do
      let(:user) { Factory.create!(:user, role: 'driver') }

      let!(:tasks) do
        [
          Factory.create!(:task, pickup_point: { lat: 44.106669, lng: -73.935835 }),
          Factory.create!(:task, pickup_point: { lat: 44.106668, lng: -73.935834 }),
          Factory.create!(:task, pickup_point: { lat: 44.106667, lng: -73.935833 })
        ]
      end

      before(:each) do
        Factory.create!(:task, state: 'assigned')
        Factory.create!(:task, state: 'done')
      end

      it 'renders tasks with status "created"' do
        request_block.call

        expect(last_response.status).to eq 200
        expect(json_body.map { |t| t['id'] }).to eq tasks.reverse.map { |t| t.id.to_s }
      end
    end

    include_examples 'authentication required'
  end

  describe 'PUT /tasks/:id/assign' do
    let(:request_block) do
      lambda do
        put "/tasks/#{task.id}/assign", {}, headers
      end
    end

    let(:task) { Factory.create!(:task) }
    let(:user) { Factory.create!(:user, role: 'driver') }

    context 'given a valid token' do
      it 'assigns task to a driver' do
        request_block.call

        expect(last_response.status).to eq 204
        task.reload
        expect(task.state).to eq 'assigned'
        expect(task.user).to eq user
      end
    end

    context 'given a manager token' do
      let(:user) { Factory.create!(:user, role: 'manager') }

      it 'does not update a task' do
        request_block.call

        expect(last_response.status).to eq 403
        expect(last_response.body).to eq 'Forbidden'
      end
    end

    context 'given an assigned task' do
      let(:task) { Factory.create!(:task, state: 'assigned') }

      it 'does not update a task' do
        request_block.call

        expect(last_response.status).to eq 422
        expect(last_response.body).to eq 'Event \'assign\' cannot transition from \'assigned\'. '
      end
    end

    context 'given a done task' do
      let(:task) { Factory.create!(:task, state: 'done') }

      it 'does not update a task' do
        request_block.call

        expect(last_response.status).to eq 422
        expect(last_response.body).to eq 'Event \'assign\' cannot transition from \'done\'. '
      end
    end

    context 'given a not existing task' do
      let(:task) { Factory.build(:task, id: '123') }

      it 'does not update a task' do
        request_block.call

        expect(last_response.status).to eq 404
      end
    end

    include_examples 'authentication required'
  end

  describe 'PUT /tasks/:id/finish' do
    let(:request_block) do
      lambda do
        put "/tasks/#{task.id}/finish", {}, headers
      end
    end
    let(:user) { Factory.create!(:user, role: 'driver') }
    let(:task) { Factory.create!(:task, state: 'assigned', user: user) }

    context 'given a valid token' do
      it 'finishes a task' do
        request_block.call

        expect(last_response.status).to eq 204
        expect(task.reload.state).to eq 'done'
      end
    end

    context 'given a done task' do
      let(:task) { Factory.create!(:task, state: 'done', user: user) }

      it 'does not update a task' do
        request_block.call

        expect(last_response.status).to eq 422
        expect(last_response.body).to eq 'Event \'finish\' cannot transition from \'done\'. '
      end
    end

    context 'given an another user\'s task' do
      let(:task) { Factory.create!(:task, state: 'assigned', user: Factory.create(:user)) }

      it 'does not update a task' do
        request_block.call

        expect(last_response.status).to eq 403
        expect(last_response.body).to eq 'Forbidden'
      end
    end

    include_examples 'authentication required'
  end
end
