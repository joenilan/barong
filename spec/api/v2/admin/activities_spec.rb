# frozen_string_literal: true

require 'spec_helper'

describe API::V2::Admin::Activities do
  include_context 'bearer authentication'

  describe 'GET /api/v2/admin/activities' do
    let!(:create_admin_permission) do
      create :permission,
             role: 'admin'
    end
    let!(:create_member_permission) do
      create :permission,
             role: 'member'
    end
    let(:do_request) { get '/api/v2/admin/activities', headers: auth_header }

    context 'admin user' do
      let!(:test_user) { create(:user, email: 'testa@gmail.com', role: 'admin') }
      let!(:first_user) { create(:user, email: 'test1@gmail.com') }
      let!(:second_user) { create(:user, email: 'test2@gmail.com') }
      let!(:first_activity) { create(:activity, topic: 'session', action: 'login', user: first_user) }
      let!(:second_activity) { create(:activity, topic: 'session', action: 'login', user: second_user) }
      let!(:third_activity) { create(:activity, topic: 'otp', action: 'otp::enable', user: second_user) }

      it 'returns list of activities' do
        get '/api/v2/admin/activities', headers: auth_header
        activities = JSON.parse(response.body)
        expect(Activity.count).to eq activities.count
        expect(Activity.first.user_ip).to eq activities[0]['user_ip']
        expect(Activity.first.user_agent).to eq activities[0]['user_agent']
        expect(Activity.first.topic).to eq activities[0]['topic']
        expect(Activity.first.action).to eq activities[0]['action']
        expect(Activity.first.result).to eq activities[0]['result']
        expect(Activity.first.user).to eq first_user
        expect(Activity.second.user).to eq second_user
      end

      it 'returns list of activities filtered by action' do
        get '/api/v2/admin/activities', headers: auth_header, params: {action: 'login'}
        activities = JSON.parse(response.body)
        expect(activities.count).to eq 2
      end

      it 'returns list of activities filtered by uid' do
        get '/api/v2/admin/activities', headers: auth_header, params: {uid: first_user.uid}
        activities = JSON.parse(response.body)
        expect(activities.count).to eq 1
      end

      it 'returns list of activities filtered by email' do
        get '/api/v2/admin/activities', headers: auth_header, params: {email: first_user.email}
        activities = JSON.parse(response.body)
        expect(activities.count).to eq 1
      end

      it 'returns list of activities filtered by topic' do
        get '/api/v2/admin/activities', headers: auth_header, params: {topic: 'otp'}
        activities = JSON.parse(response.body)
        expect(activities.count).to eq 1
      end

      it 'returns list of activities filtered by action and  uid' do
        get '/api/v2/admin/activities', headers: auth_header, params: {topic: 'session', action: 'login', uid: second_user.uid}
        activities = JSON.parse(response.body)
        expect(activities.count).to eq 1
      end
    end
  end
end
