
describe Aclize::Acl::PathsRegistry do

  it "should exist" do
    expect(defined?(described_class)).not_to be nil
  end

  describe "#new" do
    subject(:registry) { described_class.new }

    it { is_expected.to be_a described_class }

    describe "@permitted" do
      subject(:permitted) { registry.instance_eval{ @permitted } }

      it { is_expected.not_to be nil }
      it { is_expected.to be_a Array }
      it { is_expected.to be_empty }
    end

    describe "@denied" do
      subject(:denied) { registry.instance_eval{ @denied } }

      it { is_expected.not_to be nil }
      it { is_expected.to be_a Array }
      it { is_expected.to be_empty }
    end
  end

  describe "instance" do
    subject(:registry) { described_class.new }

    it { is_expected.to respond_to :permitted }
    it { is_expected.to respond_to :denied }
    it { is_expected.to respond_to :permit }
    it { is_expected.to respond_to :deny }

    describe "#permitted" do
      subject(:permitted) { registry.permitted }

      before do
        registry.instance_eval{ @permitted << "a/permitted/path" }
      end

      it { is_expected.to eq registry.instance_eval{ @permitted } }
    end

    describe "#denied" do
      subject(:denied) { registry.denied }

      before do
        registry.instance_eval{ @denied << "a/denied/path" }
      end

      it { is_expected.to eq registry.instance_eval{ @denied } }
    end

    describe "#permit" do
      let(:paths) { ["path/a", "path/b", "path/c"] }

      context "when @permitted is empty" do
        subject(:permitted) { registry.permitted }

        before do
          registry.permit paths
        end

        it { is_expected.not_to be_empty }
        it { is_expected.to eq paths }
      end

      context "when @permitted is NOT empty" do
        let(:other_paths) { ["path/1", "path/2"] }
        subject(:permitted) { registry.permitted }

        before do
          registry.permit other_paths
          registry.permit paths
        end

        it { is_expected.not_to be_empty }
        it { is_expected.not_to eq paths }
        it { is_expected.to eq(other_paths + paths) }
      end

      context "when @permitted contains the same paths" do
        subject(:permitted) { registry.permitted }

        before do
          3.times do
            registry.permit paths
          end
        end

        it { is_expected.not_to be_empty }
        it { is_expected.to eq paths }
      end
    end

    describe "#deny" do
      let(:paths) { ["path/a", "path/b", "path/c"] }

      context "when @denied is empty" do
        subject(:denied) { registry.denied }

        before do
          registry.deny paths
        end

        it { is_expected.not_to be_empty }
        it { is_expected.to eq paths }
      end

      context "when @denied is NOT empty" do
        let(:other_paths) { ["path/1", "path/2"] }
        subject(:denied) { registry.denied }

        before do
          registry.deny other_paths
          registry.deny paths
        end

        it { is_expected.not_to be_empty }
        it { is_expected.not_to eq paths }
        it { is_expected.to eq(other_paths + paths) }
      end

      context "when @denied contains the same paths" do
        subject(:denied) { registry.denied }

        before do
          3.times do
            registry.deny paths
          end
        end

        it { is_expected.not_to be_empty }
        it { is_expected.to eq paths }
      end
    end

    describe "#permitted?" do
      context "by default" do
        it "should be false for 'posts'" do
          expect(registry.permitted? 'posts').to eq false
        end

        it "should be false for 'posts/1'" do
          expect(registry.permitted? 'posts/1').to eq false
        end
      end

      context "when 'posts.*' is permitted" do
        before do
          registry.permit 'posts.*'
        end

        it "should be true for 'posts' path" do
          expect(registry.permitted? 'posts').to eq true
        end

        it "should be true for 'posts/1' path" do
          expect(registry.permitted? 'posts/1').to eq true
        end

        it "should be true for 'posts/whatever/you/want' path" do
          expect(registry.permitted? 'posts/whatever/you/want').to be true
        end

        it "should be false for '/posts'" do
          expect(registry.permitted? '/posts').to be false
        end

        it "should be false for 'comments' path" do
          expect(registry.permitted? 'comments').to be false
        end

        context "and 'posts/.*' is denied" do
          before do
            registry.deny 'posts/.*'
          end

          it "should be true for 'posts' path" do
            expect(registry.permitted? 'posts').to be true
          end

          it "should be true for 'posts_or_something_else'" do
            expect(registry.permitted? 'posts_or_something_else').to be true
          end

          it "should be false for 'posts/' path" do
            expect(registry.permitted? 'posts/').to be false
          end

          it "should be false for 'posts/1' path" do
            expect(registry.permitted? 'posts/1').to be false
          end
        end

        context "and 'posts/[0-9]+' is denied" do
          before do
            registry.deny 'posts/[0-9]+'
          end

          it "should be true for 'posts' path" do
            expect(registry.permitted? 'posts').to be true
          end

          it "should be true for 'posts/' path" do
            expect(registry.permitted? 'posts/').to be true
          end

          it "should be true for 'posts/new' path" do
            expect(registry.permitted? 'posts/new').to be true
          end

          it "should be true for 'posts/1/edit' path" do
            expect(registry.permitted? 'posts/1/edit').to be true
          end

          it "should be false for 'posts/1' path" do
            expect(registry.permitted? 'posts/1').to be false
          end
        end

        context "and 'posts.*' is denied" do
          before do
            registry.deny 'posts.*'
          end

          it "should be false for 'posts'" do
            expect(registry.permitted? 'posts').to be false
          end

          it "should be false for 'posts/' path" do
            expect(registry.permitted? 'posts/').to be false
          end

          it "should be false for 'posts/new' path" do
            expect(registry.permitted? 'posts/new').to be false
          end

          it "should be false for 'posts/1/edit' path" do
            expect(registry.permitted? 'posts/1/edit').to be false
          end

          it "should be false for 'posts/1' path" do
            expect(registry.permitted? 'posts/1').to be false
          end

          it "should be false for 'posts/whatever/you/want' path" do
            expect(registry.permitted? 'posts/whatever/you/want').to be false
          end

          it "should be false for 'posts_or_something_else'" do
            expect(registry.permitted? 'posts_or_something_else').to be false
          end
        end
      end

      context "when 'posts(/\d+)?(/\w+)?' is permitted" do
        before do
          registry.permit 'posts(/\d+)?(/\w+)?'
        end

        it "should be true for 'posts' path" do
          expect(registry.permitted? 'posts').to be true
        end

        it "should be true for 'posts/new' path" do
          expect(registry.permitted? 'posts/new').to be true
        end

        it "should be true for 'posts/1' path" do
          expect(registry.permitted? 'posts/1').to be true
        end

        it "should be true for 'posts/1/edit'" do
          expect(registry.permitted? 'posts/1/edit').to be true
        end

        it "should be false for 'posts/1/edit/something'" do
          expect(registry.permitted? 'posts/1/edit/something').to be false
        end

        context "when 'posts.*' is denied" do
          before do
            registry.deny 'posts.*'
          end

          it "should be false for 'posts'" do
            expect(registry.permitted? 'posts').to be false
          end

          it "should be false for 'posts/' path" do
            expect(registry.permitted? 'posts/').to be false
          end

          it "should be false for 'posts/new' path" do
            expect(registry.permitted? 'posts/new').to be false
          end

          it "should be false for 'posts/1/edit' path" do
            expect(registry.permitted? 'posts/1/edit').to be false
          end

          it "should be false for 'posts/1' path" do
            expect(registry.permitted? 'posts/1').to be false
          end

          it "should be false for 'posts/whatever/you/want' path" do
            expect(registry.permitted? 'posts/whatever/you/want').to be false
          end

          it "should be false for 'posts_or_something_else'" do
            expect(registry.permitted? 'posts_or_something_else').to be false
          end
        end
      end
    end

    describe "#denied?" do
      context "by default" do
        it "should be false for 'posts' path" do
          expect(registry.denied? 'posts').to be false
        end

        it "should be false for 'posts/1'" do
          expect(registry.denied? 'posts/1').to be false
        end
      end

      context "when 'posts/.*' is denied" do
        before do
          registry.deny 'posts/.*'
        end

        it "should be false for 'posts' path" do
          expect(registry.denied? 'posts').to be false
        end

        it "should be true for 'posts/1'" do
          expect(registry.denied? 'posts/1').to be true
        end

        it "should be true for 'posts/something'" do
          expect(registry.denied? 'posts/something').to be true
        end
      end

      context "when 'posts/(\d+)?/.*' is denied" do
        before do
          registry.deny 'posts/(\d+)?/.*'
        end

        it "should be false for 'posts' path" do
          expect(registry.denied? 'posts').to be false
        end

        it "should be false for 'posts/1'" do
          expect(registry.denied? 'posts/1').to be false
        end

        it "should be false for 'posts/something'" do
          expect(registry.denied? 'posts/something').to be false
        end

        it "should be true for 'posts/1/something'" do
          expect(registry.denied? 'posts/1/something').to be true
        end
      end
    end
  end
end