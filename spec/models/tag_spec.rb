require 'spec_helper'

describe Tag do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_uniqueness_of :name}
  end

  describe 'associations' do
    it {should have_and_belong_to_many :items}
  end

  describe 'methods' do
    describe '.to_tag_list' do
      subject do
        described_class.to_tag_list(Tag.all)
      end

      context 'when there is no tags' do
        before { Tag.count.should == 0 }

        it {should == ''}
      end

      context 'when there is 1 tag' do
        before { create(:tag, name: 'Tag1') }

        it {should == 'Tag1'}
      end

      context 'when there are 2 tags' do
        before { create(:tag, name: 'Tag1') }
        before { create(:tag, name: 'Tag2') }

        it {should == 'Tag1,Tag2'}
      end
    end

    describe '.from_tag_list' do
      def described_method
        described_class.from_tag_list(string)
      end

      subject do
        described_method
      end

      context 'when string is empty' do
        let(:string) {''}

        it {should be_empty}
      end

      context 'when string only contains separator' do
        let(:string) {described_class::SEPARATOR * 3}

        it {should be_empty}
      end

      context 'when string is valid' do
        let(:tag_name_1) {'Tag1'}
        let(:tag_name_2) {'Tag2'}
        let(:string) {[tag_name_1,tag_name_2].join(described_class::SEPARATOR)}

        describe 'returned result' do
          before { create(:tag, name: tag_name_1) }
          before { create(:tag, name: tag_name_2) }

          describe 'finding tag 1' do
            let(:string) {tag_name_1}

            it {should include Tag.where(name: tag_name_1).first}
          end

          describe 'finding tag 2' do
            let(:string) {tag_name_2}

            it {should include Tag.where(name: tag_name_2).first}
          end

          describe 'finding tag 1 & 2' do
            let(:string) {[tag_name_1,tag_name_2].join(described_class::SEPARATOR)}

            it {should include Tag.where(name: tag_name_1).first}
            it {should include Tag.where(name: tag_name_2).first}
          end
        end

        context 'when Tag with the tag_name_1 does not exist' do
          before {Tag.count.should == 0}

          it 'creates a Tag with the name' do
            expect {described_method}.to change(Tag, :count).by(2)
          end
        end

        context 'when Tag with the tag_name_1 does exist, but not tag_name_2' do
          before { create(:tag, name: tag_name_1) }

          it 'creates a Tag with the name' do
            expect {described_method}.to change(Tag, :count).by(1)
          end
        end

        context 'when Tag with the tag_name_1 does exist, but not tag_name_2' do
          before { create(:tag, name: tag_name_1) }
          before { create(:tag, name: tag_name_2) }

          it 'creates a Tag with the name' do
            expect {described_method}.to_not change(Tag, :count)
          end
        end
      end
    end
  end
end
