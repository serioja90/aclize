
describe Aclize do
  it 'has a version number' do
    expect(Aclize::VERSION).not_to be nil
  end

  describe "ActionController::Base" do
    subject { ActionController::Base }

    it "should be defined" do
      expect(defined?(ActionController::Base)).not_to be nil
    end

    it { is_expected.to be_aclized }
    it { is_expected.to respond_to :if_unauthorized }

    describe "instance" do
      subject(:instance) { ActionController::Base.new }

      describe "#get_acl_definition" do
        subject(:acl) { instance.instance_eval { get_acl_definition } }

        it { is_expected.to be_a Aclize::Acl }
      end

      describe "#get_current_role" do
        subject(:role) { instance.instance_eval { get_current_role } }

        context "by default" do
          it { is_expected.to be :all }
        end

        context "when set" do
          before do
            instance.instance_eval{ @_aclize_current_role = :user }
          end

          it { is_expected.to eq instance.instance_eval{ @_aclize_current_role } }
        end
      end

      describe "#set_current_role" do
        subject(:role) { instance.instance_eval{ get_current_role } }

        before do
          instance.instance_eval { set_current_role(:user) }
        end

        it "should update the current role" do
          expect(role).to eq(:user)
        end
      end

      describe "#acl_for" do
        subject(:acl) { instance.instance_eval { get_acl_definition } }

        it { is_expected.to receive(:setup).with(:user).once }

        it "should setup controllers" do
          expect_any_instance_of(Aclize::Acl::Role).to receive(:controllers).once
        end

        it "should setup paths" do
          expect_any_instance_of(Aclize::Acl::Role).to receive(:paths).once
        end

        after do
          instance.instance_eval do
            acl_for :user do
              controllers do
                permit :posts
              end

              paths do
                permit "comments(/.*)"
              end
            end
          end
        end
      end

      describe "#filter_access!" do
        it "should call :treat_as" do
          expect(instance).to receive(:treat_as).with(:user).once
        end

        after do
          instance.instance_eval { set_current_role :user }
          instance.instance_eval { filter_access! }
        end
      end

      describe "#treat_as" do
        let(:request) { double("Request") }

        before do
          allow(instance).to receive(:request).and_return request
          instance.instance_eval do
            acl_for :user do
              controllers do
                permit :posts, only: [:index, :show]
              end
            end
          end
        end

        context "when controller is :comments" do
          before do
            allow(request).to receive(:path_info).and_return "comments/index"
            allow(instance).to receive(:controller_name).and_return "comments"
            allow(instance).to receive(:action_name).and_return "index"
          end

          it "should call :unauthorize! once" do
            expect(instance).to receive(:unauthorize!).once
          end
        end

        context "when controller is :posts" do
          before do
            allow(request).to receive(:path_info).and_return "posts/index"
            allow(instance).to receive(:controller_name).and_return "posts"
            allow(instance).to receive(:action_name).and_return "index"
          end

          it "should NOT call :unauthorize!" do
            expect(instance).not_to receive(:unauthorize!)
          end
        end

        context "when controller is :posts and action is :new" do
          before do
            allow(request).to receive(:path_info).and_return "posts/new"
            allow(instance).to receive(:controller_name).and_return "posts"
            allow(instance).to receive(:action_name).and_return "new"
          end

          it "should call call :unauthorize!" do
            expect(instance).not_to receive(:unauthorize!).once
          end
        end

        after do
          instance.instance_eval { treat_as :user }
        end
      end
    end
  end
end
