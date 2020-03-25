require 'rails_helper'

RSpec.describe Swimmer, type: :model do
  let(:swimmer) { build(:swimmer)  }

  it 'builds properly' do
    expect(swimmer.valid?).to be true
  end

  it 'creates successfully' do
    swimmer.save!
  end

  describe 'validations' do
    describe '#usms_permanent_id' do
      it 'disallows nil' do
        swimmer.usms_permanent_id = nil
        expect(swimmer.valid?).to be false
      end

      it 'disallows empty string' do
        swimmer.usms_permanent_id = ''
        expect(swimmer.valid?).to be false
      end

      it 'disallows duplicates' do
        swimmer.save!
        swimmer2 = build(:swimmer)
        expect(swimmer2.valid?).to be true
        swimmer2.usms_permanent_id = swimmer.usms_permanent_id
        expect(swimmer2.valid?).to be false
      end
    end

    describe '#gender' do
      it 'allows "M"' do
        swimmer.gender = 'M'
        expect(swimmer.valid?).to be true
      end

      it 'allows "F"' do
        swimmer.gender = 'F'
        expect(swimmer.valid?).to be true
      end

      it 'disallows invalid value' do
        swimmer.gender = 'f'
        expect(swimmer.valid?).to be false
      end
    end

    describe '#birth_date' do
      it 'disallows nil' do
        swimmer.birth_date = nil
        expect(swimmer.valid?).to be false
      end
    end
  end
end
