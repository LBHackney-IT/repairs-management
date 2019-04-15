require 'rails_helper'

describe WorkOrderReferenceFinder do
  describe '#find' do
    it 'extracts 8 digit numbers' do
      text = '10123456 201234567 3012345 40123456'

      refs = WorkOrderReferenceFinder.new('90123456').find(text)

      expect(refs).to contain_exactly('10123456', '40123456')
    end

    it 'ignores the configured work order' do
      text = '90123456 40123456'

      refs = WorkOrderReferenceFinder.new('90123456').find(text)

      expect(refs).to contain_exactly('40123456')
    end
  end

  describe '#find_in_note' do
    it 'ignores servitor job refs' do
      note = build(:hackney_note, :servitor, text: 'JOB-10123456 40123456')

      refs = WorkOrderReferenceFinder.new('90123456').find_in_note(note)

      expect(refs).to contain_exactly('40123456')
    end
  end
end
