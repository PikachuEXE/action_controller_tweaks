require 'spec_helper'

describe PostsController, type: :controller do
  describe 'included modules' do
    it do
      described_class.ancestors.should include(ActionControllerTweaks)
    end
  end

  describe '::Caching' do
    describe '#set_no_cache' do
      before do
        get :index, no_cache: true
      end

      it 'includes the pre defined headeres' do
       controller.headers.deep_include?(ActionControllerTweaks::Caching::HEADERS).should be_true
     end
    end
  end

  describe '::Session' do
    describe '#set_session' do
      let(:session_key) { :key }
      let(:session_value) { 'value' }
      let(:expire_in) { 60 * 60 } # 1 hour
      let!(:time_now) { Time.new(2013, 1, 1) }
      let!(:time_before_expire) { time_now + (expire_in / 2) }
      let!(:time_after_expire) { time_now + (expire_in * 2) }

      context 'when calling it without option' do
        before do
          controller.send(:set_session, session_key, session_value)
        end

        it 'set the session' do
          session[session_key].should eq session_value
        end

        context 'with a special key' do
          let(:session_key) { ActionControllerTweaks::Session::SPECIAL_KEYS.first }

          it 'does not set the session' do
            session[session_key].should be_nil
          end
        end
      end

      context 'when calling it with option expire_in' do
        before do
          Timecop.freeze(time_now)
          controller.send(:set_session, session_key, session_value, expire_in: expire_in)
        end

        it 'set the session' do
          session[session_key].should eq session_value
        end

        context 'before expire time' do
          before do
            Timecop.travel(time_before_expire)
            # Runs before_filter
            get :index
          end

          it 'keeps the session key' do
            session[session_key].should eq session_value
          end
        end
        context 'after expire time' do
          before do
            Timecop.travel(time_after_expire)
            # Runs before_filter
            get :index
          end

          it 'keeps the session key' do
            session.key?(session_key).should be_false
          end
        end
      end

      context 'when someone screw up the special session key' do
        before do
          session[session_key] = session_value
        end

        context 'when someone set non time string in expire_at_str' do
          before do
            session['session_keys_to_expire'] = {session_key => ''}

            # Runs before_filter
            get :index
          end

          it 'destroys the session key' do
            session.key?(session_key).should be_false
          end
        end

        context 'when someone set non has to session_keys_to_expire' do
          before do
            session['session_keys_to_expire'] = []
          end

          it 'does not destroy the session key' do
            session.key?(session_key).should be_true
          end
        end
      end
    end
  end
end
