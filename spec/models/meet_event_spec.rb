require 'rails_helper'

RSpec.describe MeetEvent, type: :model do
  let(:meet_event) { build(:meet_event)  }

  it 'builds properly' do
    expect(meet_event.valid?).to be true
  end

  it 'creates successfully' do
    meet_event.save!
  end

  describe 'validations' do
    describe '#meet' do
      it 'disallows nil' do
        meet_event.meet = nil
        expect(meet_event.valid?).to be false
        puts meet_event.errors.full_messages
      end
    end

    describe '#event' do
      it 'disallows nil' do
        meet_event.event = nil
        expect(meet_event.valid?).to be false
      end
    end
  end

end


