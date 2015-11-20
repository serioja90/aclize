
describe Aclize::Acl do

  it "should exist" do
    expect(defined?(described_class)).not_to be nil
  end

  describe "#new" do
    subject(:acl){ described_class.new }

    it { is_expected.to be_a Aclize::Acl }

    it "should initizize the @roles" do
      expect(subject.roles).not_to be nil
    end

    describe "@roles" do
      subject(:roles){ acl.roles }

      it { is_expected.to be_a Hash }
      it { is_expected.not_to be_empty }
      it { is_expected.to have_key :all }

      describe ":all" do
        subject { roles[:all] }

        it { is_expected.not_to be nil }
        it { is_expected.to be_a Aclize::Acl::Role }
      end
    end
  end

  describe "instance" do
    subject(:acl){ described_class.new }

    it { is_expected.to respond_to :roles }
    it { is_expected.to respond_to :setup }

    describe "#roles" do
      subject(:roles) { acl.roles }

      it { is_expected.not_to be nil }
      it { is_expected.to be_a Hash }

      it "should eq to @roles" do
        expect(roles).to eq( acl.instance_eval { @roles } )
      end
    end

    describe "#setup" do
      let(:role) { :admin }

      it "should add a new role if not exists" do
        expect(acl.roles[role]).to be nil
        acl.setup(role) {}
        expect(acl.roles[role]).to be_a Aclize::Acl::Role
      end

      it "should call :instance_eval on the Aclize::Acl::Role" do
        expect_any_instance_of(Aclize::Acl::Role).to receive(:instance_eval).once
        acl.setup(role) {}
      end
    end
  end
end