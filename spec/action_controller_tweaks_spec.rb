require "spec_helper"

describe NotController do
  describe "::Session" do
    context "when included by a class without `before_action`" do
      it "raises error" do
        expect do
          described_class.class_eval do
            include ActionControllerTweaks::Session
          end
        end.to raise_error(NotImplementedError)
      end
    end
  end
end

describe PostsController, type: :controller do
  describe "included modules" do
    specify do
      expect(described_class.ancestors).to include(ActionControllerTweaks)
    end
  end

  describe "::Caching" do
    describe "#set_no_cache" do
      before do
        if Rails::VERSION::MAJOR >= 5
          get :index, params: { no_cache: true }
        else
          get :index, no_cache: true
        end
      end

      it "includes the pre defined headeres" do
        header_hash = controller.headers.to_h
        is_rails_6_1_plus = Gem::Requirement.create([">= 6.1"]).
          satisfied_by?(::Rails.gem_version)
        is_rails_7_1_plus = Gem::Requirement.create([">= 7.1"]).
          satisfied_by?(::Rails.gem_version)

        aggregate_failures do
          ActionControllerTweaks::Caching::HEADERS.each_pair do |header_name, header_value|
            # Workaround for rails 6.1 updating value
            # when input value contains `no-store`
            #
            # https://github.com/rails/rails/issues/40798
            #
            # Rails 7.1 emit header names in lower case
            if header_name.downcase == "cache-control" && is_rails_6_1_plus
              expect(header_hash[is_rails_7_1_plus ? header_name.downcase : header_name]).to include("no-store")
            else
              expect(header_hash[is_rails_7_1_plus ? header_name.downcase : header_name]).to eq(header_value)
            end
          end
        end
      end
    end
  end

  describe "::Session" do
    let(:session_key) { :key }
    let(:session_value) { "value" }

    describe "#set_session" do
      let(:expire_in) { 60 * 60 } # 1 hour
      let(:expire_at) { Time.new(2014, 1, 1).in_time_zone }
      let(:time_now) { Time.new(2013, 1, 1).in_time_zone }
      # Corrected option keys
      let(:expires_in) { expire_in }
      let(:expires_at) { expire_at }

      context "when calling it without option" do
        let :set_session do
          controller.send(:set_session, session_key, session_value)
        end

        context "with normal key" do
          before do
            set_session
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end
        end

        context "with a reserved key" do
          let(:session_key) { ActionControllerTweaks::Session::RESERVED_SESSION_KEYS.first }

          it "raise error" do
            expect { set_session }.
              to raise_error(ActionControllerTweaks::Session::Errors::ReservedSessionKeyConflict)
          end
        end
      end

      context "for old option keys" do
        context "when calling it with option expire_in" do
          let!(:time_before_expire) { time_now + (expire_in / 2) }
          let!(:time_after_expire) { time_now + (expire_in * 2) }

          before do
            Timecop.freeze(time_now)
            controller.send(:set_session, session_key, session_value, expire_in: expire_in)
          end

          after do
            Timecop.return
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          context "before expire time" do
            before do
              Timecop.travel(time_before_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session[session_key]).to eq session_value
            end
          end
          context "after expire time" do
            before do
              Timecop.travel(time_after_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session.key?(session_key)).to be false
            end
          end
        end

        context "when calling it with no option" do
          before do
            controller.send(:set_session, session_key, session_value)
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          it "does NOT add the session key to `session_keys_to_expire`" do
            expect(session["session_keys_to_expire"].keys).to_not include(session_key)
          end
        end

        context "when calling it with option expire_at" do
          let!(:time_before_expire) { expire_at - 1 }
          let!(:time_after_expire) { expire_at + 1 }

          before do
            Timecop.freeze(time_now)
            controller.send(:set_session,
              session_key, session_value, expire_at: expire_at)
          end

          after do
            Timecop.return
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          context "before expire time" do
            before do
              Timecop.travel(time_before_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session[session_key]).to eq session_value
            end
          end
          context "after expire time" do
            before do
              Timecop.travel(time_after_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session.key?(session_key)).to be false
            end
          end
        end
      end
      context "for new option keys" do
        context "when calling it with option expires_in" do
          let!(:time_before_expire) { time_now + (expires_in / 2) }
          let!(:time_after_expire) { time_now + (expires_in * 2) }

          before do
            Timecop.freeze(time_now)
            controller.send(:set_session,
              session_key, session_value, expires_in: expires_in)
          end

          after do
            Timecop.return
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          context "before expire time" do
            before do
              Timecop.travel(time_before_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session[session_key]).to eq session_value
            end
          end
          context "after expire time" do
            before do
              Timecop.travel(time_after_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session.key?(session_key)).to be false
            end
          end
        end

        context "when calling it with option expires_at" do
          let!(:time_before_expire) { expires_at - 1 }
          let!(:time_after_expire) { expires_at + 1 }

          before do
            Timecop.freeze(time_now)
            controller.send(:set_session,
              session_key, session_value, expire_at: expires_at)
          end

          after do
            Timecop.return
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          context "before expire time" do
            before do
              Timecop.travel(time_before_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session[session_key]).to eq session_value
            end
          end
          context "after expire time" do
            before do
              Timecop.travel(time_after_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session.key?(session_key)).to be false
            end
          end
        end
      end

      context "when option value with different types is passed into options" do
        let(:method_call) do
          controller.send(:set_session, session_key, session_value, options)
        end

        context "for old option keys" do
          context "for expire_in" do
            let(:options) { {expire_in: expire_in.to_s} }

            specify do
              expect { method_call }.
                to raise_error(ActionControllerTweaks::Session::InvalidOptionValue)
            end
          end
          context "for expire_at" do
            context "with a Hash" do
              # String#to_time would be nil if format invalid
              let(:options) { {expire_at: {}} }

              specify do
                expect { method_call }.
                  to raise_error(ActionControllerTweaks::Session::InvalidOptionValue)
              end
            end
            context "with a blank String" do
              # String#to_time would be nil if format invalid
              let(:options) { {expire_at: ""} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a time String" do
              let(:options) { {expire_at: expire_at.to_s} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a Time" do
              let(:options) { {expire_at: expire_at.to_time} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a Date" do
              let(:options) { {expire_at: expire_at.to_date} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a DateTime" do
              let(:options) { {expire_at: expire_at.in_time_zone} }

              specify { expect { method_call }.to_not raise_error }
            end
          end
        end
        context "for new option keys" do
          context "for expires_in" do
            let(:options) { {expires_in: expires_in.to_s} }

            specify do
              expect { method_call }.
                to raise_error(ActionControllerTweaks::Session::InvalidOptionValue)
            end
          end
          context "for expires_at" do
            context "with a Hash" do
              # String#to_time would be nil if format invalid
              let(:options) { {expires_at: {}} }

              specify do
                expect { method_call }.
                  to raise_error(ActionControllerTweaks::Session::InvalidOptionValue)
              end
            end
            context "with a blank String" do
              # String#to_time would be nil if format invalid
              let(:options) { {expires_at: ""} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a time String" do
              let(:options) { {expires_at: expire_at.to_s} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a Time" do
              let(:options) { {expires_at: expire_at.to_time} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a Date" do
              let(:options) { {expires_at: expire_at.to_date} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a DateTime" do
              let(:options) { {expires_at: expire_at.in_time_zone} }

              specify { expect { method_call }.to_not raise_error }
            end
          end
        end
      end

      context "when someone screw up the special session key" do
        before do
          session[session_key] = session_value
        end

        context "when someone set non time string in expire_at_str" do
          before do
            session["session_keys_to_expire"] = {session_key => ""}

            # Runs before_action
            get :index
          end

          it "destroys the session key" do
            expect(session.key?(session_key)).to be false
          end
        end

        context "when someone set non-hash to session_keys_to_expire" do
          before do
            session["session_keys_to_expire"] = []
          end

          it "does not destroy the session key" do
            expect(session.key?(session_key)).to be true
          end
        end
      end
    end

    describe "#set_session_with_expiry" do
      let(:expire_in) { 60 * 60 } # 1 hour
      let(:expire_at) { Time.new(2014, 1, 1).in_time_zone }
      let(:time_now) { Time.new(2013, 1, 1).in_time_zone }
      # Corrected option keys
      let(:expires_in) { expire_in }
      let(:expires_at) { expire_at }

      let(:method_call) do
        controller.send(:set_session_with_expiry, session_key, session_value, options)
      end

      context "when call with no options" do
        let!(:options) { {} }

        specify do
          expect { method_call }.
            to raise_error(ActionControllerTweaks::Session::Errors::InvalidOptionKeys)
        end
      end
      context "when call with invalid option keys" do
        let!(:options) { {key: :value} }

        specify do
          expect { method_call }.
            to raise_error(ActionControllerTweaks::Session::Errors::InvalidOptionKeys)
        end
      end
      context "when call with valid option keys" do
        context "like expire_in" do
          let!(:options) { {expire_in: 1.day} }

          specify { expect { method_call }.to_not raise_error }
        end
        context "like expire_at" do
          let!(:options) { {expire_at: 1.day.from_now} }

          specify { expect { method_call }.to_not raise_error }
        end
        context "like expires_in" do
          let!(:options) { {expires_in: 1.day} }

          specify { expect { method_call }.to_not raise_error }
        end
        context "like expires_at" do
          let!(:options) { {expires_at: 1.day.from_now} }

          specify { expect { method_call }.to_not raise_error }
        end
      end

      context "for old option keys" do
        context "when calling it with option expire_in" do
          let!(:time_before_expire) { time_now + (expire_in / 2) }
          let!(:time_after_expire) { time_now + (expire_in * 2) }

          before do
            Timecop.freeze(time_now)
            controller.send(:set_session_with_expiry,
              session_key, session_value, expire_in: expire_in)
          end

          after do
            Timecop.return
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          context "before expire time" do
            before do
              Timecop.travel(time_before_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session[session_key]).to eq session_value
            end
          end
          context "after expire time" do
            before do
              Timecop.travel(time_after_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session.key?(session_key)).to be false
            end
          end
        end

        context "when calling it with no option" do
          let(:method_call) do
            controller.send(:set_session_with_expiry, session_key, session_value)
          end

          specify do
            expect { method_call }.
              to raise_error(ActionControllerTweaks::Session::Errors::InvalidOptionKeys)
          end
        end

        context "when calling it with option expire_at" do
          let!(:time_before_expire) { expire_at - 1 }
          let!(:time_after_expire) { expire_at + 1 }

          before do
            Timecop.freeze(time_now)
            controller.send(:set_session_with_expiry,
              session_key, session_value, expire_at: expire_at)
          end

          after do
            Timecop.return
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          context "before expire time" do
            before do
              Timecop.travel(time_before_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session[session_key]).to eq session_value
            end
          end
          context "after expire time" do
            before do
              Timecop.travel(time_after_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session.key?(session_key)).to be false
            end
          end
        end
      end
      context "for new option keys" do
        context "when calling it with option expires_in" do
          let!(:time_before_expire) { time_now + (expires_in / 2) }
          let!(:time_after_expire) { time_now + (expires_in * 2) }

          before do
            Timecop.freeze(time_now)
            controller.send(:set_session_with_expiry,
              session_key, session_value, expires_in: expires_in)
          end

          after do
            Timecop.return
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          context "before expire time" do
            before do
              Timecop.travel(time_before_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session[session_key]).to eq session_value
            end
          end
          context "after expire time" do
            before do
              Timecop.travel(time_after_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session.key?(session_key)).to be false
            end
          end
        end

        context "when calling it with option expires_at" do
          let!(:time_before_expire) { expires_at - 1 }
          let!(:time_after_expire) { expires_at + 1 }

          before do
            Timecop.freeze(time_now)
            controller.send(:set_session_with_expiry,
              session_key, session_value, expire_at: expires_at)
          end

          after do
            Timecop.return
          end

          it "set the session" do
            expect(session[session_key]).to eq session_value
          end

          context "before expire time" do
            before do
              Timecop.travel(time_before_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session[session_key]).to eq session_value
            end
          end
          context "after expire time" do
            before do
              Timecop.travel(time_after_expire)
              # Runs before_action
              get :index
            end

            it "keeps the session key" do
              expect(session.key?(session_key)).to be false
            end
          end
        end
      end

      context "when option value with different types is passed into options" do
        let(:method_call) do
          controller.send(:set_session_with_expiry, session_key, session_value, options)
        end

        context "for old option keys" do
          context "for expire_in" do
            let(:options) { {expire_in: expire_in.to_s} }

            specify do
              expect { method_call }.
                to raise_error(ActionControllerTweaks::Session::InvalidOptionValue)
            end
          end
          context "for expire_at" do
            context "with a Hash" do
              # String#to_time would be nil if format invalid
              let(:options) { {expire_at: {}} }

              specify do
                expect { method_call }.
                  to raise_error(ActionControllerTweaks::Session::InvalidOptionValue)
              end
            end
            context "with a blank String" do
              # String#to_time would be nil if format invalid
              let(:options) { {expire_at: ""} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a time String" do
              let(:options) { {expire_at: expire_at.to_s} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a Time" do
              let(:options) { {expire_at: expire_at.to_time} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a Date" do
              let(:options) { {expire_at: expire_at.to_date} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a DateTime" do
              let(:options) { {expire_at: expire_at.in_time_zone} }

              specify { expect { method_call }.to_not raise_error }
            end
          end
        end
        context "for new option keys" do
          context "for expires_in" do
            let(:options) { {expires_in: expires_in.to_s} }

            specify do
              expect { method_call }.
                to raise_error(ActionControllerTweaks::Session::InvalidOptionValue)
            end
          end
          context "for expires_at" do
            context "with a Hash" do
              # String#to_time would be nil if format invalid
              let(:options) { {expires_at: {}} }

              specify do
                expect { method_call }.
                  to raise_error(ActionControllerTweaks::Session::InvalidOptionValue)
              end
            end
            context "with a blank String" do
              # String#to_time would be nil if format invalid
              let(:options) { {expires_at: ""} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a time String" do
              let(:options) { {expires_at: expire_at.to_s} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a Time" do
              let(:options) { {expires_at: expire_at.to_time} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a Date" do
              let(:options) { {expires_at: expire_at.to_date} }

              specify { expect { method_call }.to_not raise_error }
            end
            context "with a DateTime" do
              let(:options) { {expires_at: expire_at.in_time_zone} }

              specify { expect { method_call }.to_not raise_error }
            end
          end
        end
      end
    end
  end
end
