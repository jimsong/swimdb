require 'rails_helper'

RSpec.describe SwimmerAlias, type: :model do
  let(:swimmer_alias) { build(:swimmer_alias)  }

  it 'builds properly' do
    expect(swimmer_alias.valid?).to be true
  end

  it 'creates successfully' do
    swimmer_alias.save!
  end

  describe 'validations' do
    it 'disallows duplicate names' do
      swimmer_alias.save!
      swimmer_alias2 = build(:swimmer_alias)
      expect(swimmer_alias2.valid?).to be true
      swimmer_alias2.first_name = swimmer_alias.first_name
      swimmer_alias2.last_name = swimmer_alias.last_name
      expect(swimmer_alias2.valid?).to be false
    end
  end

end
