require 'rails_helper'

RSpec.describe Swimmer, type: :model do
  let(:swimmer) { build(:swimmer) }

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
        expect(swimmer2.save).to be false
      end
    end

    describe '#gender' do
      it 'allows nil' do
        swimmer.gender = nil
        expect(swimmer.valid?).to be true
        swimmer.save!
      end

      it 'allows "M"' do
        swimmer.gender = 'M'
        expect(swimmer.valid?).to be true
      end

      it 'allows "W"' do
        swimmer.gender = 'W'
        expect(swimmer.valid?).to be true
      end

      it 'disallows invalid value' do
        swimmer.gender = 'w'
        expect(swimmer.valid?).to be false
      end
    end
  end

  describe 'after_save' do
    let(:swimmer) do
      build(:swimmer, first_name: 'Ryan', last_name: 'Lochte')
    end

    before do
      swimmer.save!
    end

    context 'on creation' do
      it 'creates a new SwimmerAlias' do
        swimmer_alias = SwimmerAlias.find_by(
          first_name: 'Ryan',
          last_name: 'Lochte'
        )
        expect(swimmer_alias).to_not be_nil
      end
    end

    context 'with a SwimmerAlias of a different name' do
      before do
        swimmer.first_name = 'Michael'
        swimmer.last_name = 'Phelps'
        swimmer.save!
      end

      it 'keeps the existing SwimmerAlias' do
        swimmer_alias = SwimmerAlias.find_by(
          first_name: 'Ryan',
          last_name: 'Lochte'
        )
        expect(swimmer_alias).to_not be_nil
      end

      it 'creates a new SwimmerAlias' do
        swimmer_alias = SwimmerAlias.find_by(
          first_name: 'Michael',
          last_name: 'Phelps'
        )
        expect(swimmer_alias).to_not be_nil
      end
    end

    context 'with a SwimmerAlias of the same name' do
      it 'does not create a new SwimmerAlias' do
        swimmer.usms_permanent_id = 'changed'
        swimmer.save!
        count = SwimmerAlias.where(
          first_name: 'Ryan',
          last_name: 'Lochte'
        ).count
        expect(count).to eq 1
      end
    end
  end
end
