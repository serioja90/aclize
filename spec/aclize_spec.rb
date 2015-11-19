
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

        it { is_expected.to be_a Hash }
        it { is_expected.not_to be_empty }
        it { is_expected.to have_key :controllers }
        it { is_expected.to have_key :paths }

        describe ":controllers" do
          subject { acl[:controllers] }

          it { is_expected.to be_a Hash }
          it { is_expected.to be_empty }
        end

        describe ":paths" do
          subject { acl[:paths] }

          it { is_expected.to be_a Hash }
          it { is_expected.to be_empty }
        end
      end

      describe "#define_acl" do
        subject(:acl) { instance.instance_eval { get_acl_definition } }

        before do
          new_acl_definition = new_acl
          instance.instance_eval { define_acl(new_acl_definition) }
        end

        context "for :controllers" do
          let(:new_acl) {
            {
              controllers: {
                posts: {
                  allow: ["*"],
                  deny:  ["edit", "update", "destroy"]
                }
              }
            }
          }

          it "should update the ACL definition for :controllers" do
            expect(acl[:controllers]).to eq(new_acl[:controllers].nested_under_indifferent_access)
          end

          it "should leave :paths unchanged" do
            expect(acl[:paths]).to eq({})
          end
        end

        context "for :paths" do
          let(:new_acl) {
            {
              paths: {
                allow: ["posts", "posts/.*"],
                deny:  ["posts/[0-9]+/comments", "posts/[0-9]+/comments/.*"]
              }
            }
          }

          it "should update the ACL definition for :paths" do
            expect(acl[:paths]).to eq(new_acl[:paths].nested_under_indifferent_access)
          end

          it "should leave :controllers unchanged" do
            expect(acl[:controllers]).to eq({})
          end
        end
      end
    end
  end
end
