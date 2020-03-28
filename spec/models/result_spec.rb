require 'rails_helper'

RSpec.describe Result, type: :model do
  let(:result) { build(:result)  }

  it 'builds properly' do
    expect(result.valid?).to be true
  end

  it 'creates successfully' do
    result.save!
  end

  describe 'validations' do
    describe '#meet' do
      it 'disallows nil' do
        result.meet = nil
        expect(result.valid?).to be false
      end
    end

    describe '#event' do
      it 'disallows nil' do
        result.event = nil
        expect(result.valid?).to be false
      end
    end

    describe '#age_group' do
      it 'disallows nil' do
        result.age_group = nil
        expect(result.valid?).to be false
      end
    end

    describe '#swimmer' do
      it 'disallows nil' do
        result.swimmer = nil
        expect(result.valid?).to be false
      end
    end

    describe '#time_ms' do
      it 'disallows nil' do
        result.time_ms = nil
        expect(result.valid?).to be false
      end

      it 'disallows non-numeric values' do
        result.time_ms = 'foo'
        expect(result.valid?).to be false
      end

      it 'disallows non-integers' do
        result.time_ms = 123.4
        expect(result.valid?).to be false
      end

      it 'disallows 0' do
        result.time_ms = 0
        expect(result.valid?).to be false
      end

      it 'disallows negative values' do
        result.time_ms = -1
        expect(result.valid?).to be false
      end
    end
  end
end
