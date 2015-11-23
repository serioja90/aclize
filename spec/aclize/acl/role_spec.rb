
describe Aclize::Acl::Role do

  it "should exist" do
    expect(defined?(described_class)).not_to be nil
  end

  describe "#new" do
    let(:name)     { :user }
    subject(:role) { described_class.new(name) }

    it { is_expected.to be_a described_class }

    describe "@name" do
      subject { role.instance_eval{ @name } }

      it { is_expected.not_to be nil }
      it { is_expected.to be_a String }
      it { is_expected.to eq(name.to_s) }
    end

    describe "@controllers" do
      subject { role.instance_eval{ @controllers } }

      it { is_expected.not_to be nil }
      it { is_expected.to be_a Aclize::Acl::ControllersRegistry }
    end

    describe "@paths" do
      subject { role.instance_eval{ @paths } }

      it { is_expected.not_to be nil }
      it { is_expected.to be_a Aclize::Acl::PathsRegistry }
    end
  end

  describe "instance" do
    let(:name)     { :user }
    subject(:role) { described_class.new(name) }

    it { is_expected.to respond_to :controllers }
    it { is_expected.to respond_to :paths }

    describe "#controllers" do
      context "when called without a block" do
        subject(:controllers) { role.controllers }

        it { is_expected.not_to be nil }
        it { is_expected.to be_a Aclize::Acl::ControllersRegistry }
        it { is_expected.to eq(role.instance_eval{ @controllers }) }
      end

      context "when called with a block" do
        it "should call :instance_eval on Aclize::Acl::ControllersRegistry instance" do
          expect(role.controllers).to receive(:instance_eval).once
          role.controllers {}
        end
      end
    end

    describe "#paths" do
      context "when called without a block" do
        subject(:paths) { role.paths }

        it { is_expected.not_to be nil }
        it { is_expected.to be_a Aclize::Acl::PathsRegistry }
        it { is_expected.to eq(role.instance_eval{ @paths }) }
      end

      context "when called with a block" do
        it "should call :instance_eval on Aclize::Acl::PathsRegistry instance" do
          expect(role.paths).to receive(:instance_eval).once
          role.paths {}
        end
      end
    end
  end
end