
describe Aclize::Acl::ControllersRegistry do

  it "should exist" do
    expect(defined?(described_class)).not_to be nil
  end


  describe "#new" do
    subject(:registry){ described_class.new }

    it { is_expected.to be_a described_class }

    describe "@permitted" do
      subject(:permitted) { registry.instance_eval{ @permitted } }

      it { is_expected.not_to be nil }
      it { is_expected.to be_a Hash }
      it { is_expected.to eq({"*" => []}) }
    end

    describe "@denied" do
      subject(:denied) { registry.instance_eval{ @denied } }

      it { is_expected.not_to be nil }
      it { is_expected.to be_a Hash }
      it { is_expected.to eq({"*" => []}) }
    end
  end

  describe "instance" do
    subject(:registry){ described_class.new }

    it { is_expected.to respond_to :permitted }
    it { is_expected.to respond_to :denied }
    it { is_expected.to respond_to :permit }

    describe "#permitted" do
      subject(:permitted) { registry.permitted }

      it { is_expected.to eq(registry.instance_eval{ @permitted }) }
    end

    describe "#denied" do
      subject(:denied) { registry.denied }

      it { is_expected.to eq(registry.instance_eval{ @denied }) }
    end

    describe "#permit" do
      let(:name) { :my_controller }
      before do
        registry.permit name, only: only, except: except
      end

      context "when :only and :except not specified" do
        let(:only)   { nil }
        let(:except) { nil }

        describe "@permitted" do
          subject(:permitted){ registry.instance_eval{ @permitted } }

          it { is_expected.to have_key name }

          it "should have a '*' entry for the permitted controller" do
            expect(permitted[name]).to include("*")
          end
        end

        describe "@denied" do
          subject(:denied){ registry.instance_eval{ @denied } }

          it { is_expected.to have_key name }

          it "should NOT have any entry for the permitted controller" do
            expect(denied[name]).to be_empty
          end
        end
      end

      context "when :only given" do
        let(:only)   { [:one, :two, :three] }
        let(:except) { nil }

        describe "@permitted" do
          subject(:permitted){ registry.instance_eval{ @permitted } }

          it { is_expected.to have_key name }

          it "should eq the entries from :only for the permitted controller" do
            expect(permitted[name]).to eq(only.map{|x| x.to_s })
          end
        end

        describe "@denied" do
          subject(:denied){ registry.instance_eval{ @denied } }

          it { is_expected.to have_key name }

          it "should NOT have any entry for the permitted controller" do
            expect(denied[name]).to be_empty
          end
        end
      end

      context "when only :except given" do
        let(:only)   { nil }
        let(:except) { [:one, :two, :three] }

        describe "@permitted" do
          subject(:permitted){ registry.instance_eval{ @permitted } }

          it { is_expected.to have_key name }

          it "should have a '*' entry for the permitted controller" do
            expect(permitted[name]).to include("*")
          end
        end

        describe "@denied" do
          subject(:denied){ registry.instance_eval{ @denied } }

          it { is_expected.to have_key name }

          it "should eq the entries from :except for the permitted controller" do
            expect(denied[name]).to eq(except.map{|x| x.to_s })
          end
        end
      end
    end

    describe "#permitted?" do
      context "by default" do
        it "should be false for :index action of :posts controller" do
          expect(registry.permitted? :posts, :index).to be false
        end

        it "should be false for any controller" do
          expect(registry.permitted? :posts).to be false
        end
      end

      context "when only :index action of :posts is permitted" do
        before do
          registry.permit :posts, only: :index
        end

        it "should be true for :index action of :posts controller" do
          expect(registry.permitted? :posts, :index).to be true
        end

        it "should be true for :posts controller" do
          expect(registry.permitted? :posts).to be true
        end

        it "should be false for :show action of :posts controller" do
          expect(registry.permitted? :posts, :show).to be false
        end

        it "should be false for :index action of :comments controller" do
          expect(registry.permitted? :comments, :index).to be false
        end

        it "should be false for :comments controller" do
          expect(registry.permitted? :comments).to be false
        end
      end

      context "when any action of :posts controller is permitted" do
        before do
          registry.permit :posts
        end

        it "should be true for :posts controller" do
          expect(registry.permitted? :posts).to be true
        end

        it "should be true for :index action of :posts controller" do
          expect(registry.permitted? :posts, :index).to be true
        end

        it "should be true for :show action of :posts controller" do
          expect(registry.permitted? :posts, :show).to be true
        end

        it "should be false for :comments controller" do
          expect(registry.permitted? :comments).to be false
        end

        it "should be false for :index action of :comments controller" do
          expect(registry.permitted? :comments, :index).to be false
        end
      end

      context "when any action except :destroy of :posts controller is permitted" do
        before do
          registry.permit :posts, except: :destroy
        end

        it "should be true for :posts controller" do
          expect(registry.permitted? :posts).to be true
        end

        it "should be true for :index action of :posts controller" do
          expect(registry.permitted? :posts, :index).to be true
        end

        it "should be true for :show action of :posts controller" do
          expect(registry.permitted? :posts, :show).to be true
        end

        it "should be false for :destroy action of :posts controller" do
          expect(registry.permitted? :posts, :destroy).to be false
        end

        it "should be false for :comments controller" do
          expect(registry.permitted? :comments).to be false
        end

        it "should be false for :index action of :comments controller" do
          expect(registry.permitted? :comments, :index).to be false
        end
      end

      context "when only :index action of any controller is permitted" do
        before do
          registry.permit "*", only: :index
        end

        it "should be true for :posts controller" do
          expect(registry.permitted? :posts).to be true
        end

        it "should be true for :index action of :posts controller" do
          expect(registry.permitted? :posts, :index).to be true
        end

        it "should be false for :show action of :posts controller" do
          expect(registry.permitted? :posts, :show).to be false
        end

        it "should be true for :comments controller" do
          expect(registry.permitted? :comments).to be true
        end

        it "should be true for :index action of :comments controller" do
          expect(registry.permitted? :comments, :index).to be true
        end

        it "should be false for :show action of :comments controller" do
          expect(registry.permitted? :comments, :show).to be false
        end
      end

      context "when any action of any controller is permitted" do
        before do
          registry.permit "*"
        end

        it "should be true for :posts controller" do
          expect(registry.permitted? :posts).to be true
        end

        it "should be true for :index action of :posts controller" do
          expect(registry.permitted? :posts, :index).to be true
        end

        it "should be true for :show action of :posts controller" do
          expect(registry.permitted? :posts, :show).to be true
        end

        it "should be true for :comments controller" do
          expect(registry.permitted? :comments).to be true
        end

        it "should be true for :index action of :comments controller" do
          expect(registry.permitted? :comments, :index).to be true
        end

        it "should be true for :show action of :comments controller" do
          expect(registry.permitted? :comments, :show).to be true
        end
      end

      context "when any action except :destroy of any controller is permitted" do
        before do
          registry.permit "*", except: :destroy
        end

        it "should be true for :posts controller" do
          expect(registry.permitted? :posts).to be true
        end

        it "should be true for :index action of :posts controller" do
          expect(registry.permitted? :posts, :index).to be true
        end

        it "should be true for :show action of :posts controller" do
          expect(registry.permitted? :posts, :show).to be true
        end

        it "should be false for :destroy action of :posts controller" do
          expect(registry.permitted? :posts, :destroy).to be false
        end

        it "should be true for :comments controller" do
          expect(registry.permitted? :comments).to be true
        end

        it "should be true for :index action of :comments controller" do
          expect(registry.permitted? :comments, :index).to be true
        end

        it "should be true for :show action of :comments controller" do
          expect(registry.permitted? :comments, :show).to be true
        end

        it "should be false for :destroy action of :comments controller" do
          expect(registry.permitted? :comments, :destroy).to be false
        end
      end
    end
  end
end