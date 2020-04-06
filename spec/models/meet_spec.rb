require 'rails_helper'

RSpec.describe Meet, type: :model do
  let(:meet) { build(:meet)  }

  it 'builds properly' do
    expect(meet.valid?).to be true
  end

  it 'creates successfully' do
    meet.save!
  end

  describe 'validations' do
    describe '#usms_meet_id' do
      it 'disallows nil' do
        meet.usms_meet_id = nil
        expect(meet.valid?).to be false
      end

      it 'disallows empty string' do
        meet.usms_meet_id = ''
        expect(meet.valid?).to be false
      end

      it 'disallows duplicates' do
        meet.save!
        meet2 = build(:meet)
        expect(meet2.valid?).to be true
        meet2.usms_meet_id = meet.usms_meet_id
        expect(meet2.valid?).to be false
        expect(meet2.save).to be false
      end
    end
  end
end
