require 'rails_helper'

RSpec.describe Swimmer, type: :model do
  let(:swimmer) { build(:swimmer)  }

  it 'builds properly' do
    expect(swimmer.valid?).to be true
  end

  it 'creates properly' do
    swimmer.save!
  end

  describe 'validations' do
    describe '#permanent_id' do
      it 'disallows nil' do
        swimmer.permanent_id = nil
        expect(swimmer.valid?).to be false
      end

      it 'disallows empty string' do
        swimmer.permanent_id = ''
        expect(swimmer.valid?).to be false
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
