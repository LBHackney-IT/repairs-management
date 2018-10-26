require 'rails_helper'

RSpec.describe GraphModelImporter, :db_connection do
  let!(:work_order_1) { create(:graph_work_order, reference: '00000001') }
  let!(:work_order_2) { create(:graph_work_order, reference: '00000002') }

  let(:today) { DateTime.current.beginning_of_day }

  subject { GraphModelImporter.new('test-thingy') }

  describe '#import_note' do
    it 'links work orders' do
      subject.import_note(note_id: 1,
                          logged_at: today,
                          work_order_reference: '00000001',
                          target_numbers: ['00000002'])

      expect(work_order_1.related).to eq [work_order_2]
      expect(work_order_2.related).to eq [work_order_1]
      expect(work_order_1.citations_for(work_order_2).first.note_id).to eq 1
    end

    it "creates new note records" do
      subject.import_note(note_id: 23,
                          logged_at: today,
                          work_order_reference: '00000002',
                          target_numbers: [])

      expect(Graph::Note.count).to eq 1

      Graph::Note.first.tap do |note|
        expect(note.note_id).to eq 23
        expect(note.logged_at).to eq today
        expect(note.work_order_reference).to eq '00000002'
        expect(note.source).to eq 'test-thingy'
      end
    end

    it 'ignores already processed notes' do
      Graph::Note.create!(note_id: 23, logged_at: today, source: 'test', work_order_reference: '01234567')

      subject.import_note(note_id: 23,
                          logged_at: 1.day.from_now,
                          work_order_reference: '00000002',
                          target_numbers: ['00000003'])

      expect(Graph::Note.find(23).logged_at).to eq today
    end

    context 'when a work_order is not in the graph database' do
      it 'creates a new work order model if a note belongs to an unknown work order' do
        new_work_order = build :work_order,
                               reference: '00000003',
                               created: today,
                               problem_description: 'something is broken'

        expect(Hackney::WorkOrder).to receive(:find).with('00000003') { new_work_order }

        subject.import_note(note_id: 1,
                            logged_at: today,
                            work_order_reference: '00000001',
                            target_numbers: ['00000003'])

        work_order_3 = Graph::WorkOrder.find('00000003')
        expect(work_order_3.created).to eq today
        expect(work_order_3.property_reference).to eq '1234'
        expect(work_order_3.source).to eq 'test-thingy'

        expect(work_order_1.related).to eq [work_order_3]
        expect(work_order_2.related).to eq []
        expect(work_order_3.related).to eq [work_order_1]
      end

      it "create a new work order model if the reference exists in the api" do
        new_work_order = build :work_order,
                               reference: '00000003',
                               created: today,
                               problem_description: 'something is leaking'

        expect(Hackney::WorkOrder).to receive(:find).with('00000003') { new_work_order }

        subject.import_note(note_id: 1,
                            logged_at: today,
                            work_order_reference: '00000002',
                            target_numbers: ['00000003'])

        work_order_3 = Graph::WorkOrder.find('00000003')
        expect(work_order_3.created).to eq today
        expect(work_order_3.property_reference).to eq '1234'

        expect(work_order_1.related).to eq []
        expect(work_order_2.related).to eq [work_order_3]
      end

      it "ignores the note if the reference noes not exist in the api" do
        expect(Hackney::WorkOrder).to receive(:find).with('00000003').and_raise(HackneyAPI::RepairsClient::RecordNotFoundError)

        subject.import_note(note_id: 1,
                            logged_at: today,
                            work_order_reference: '00000002',
                            target_numbers: ['00000003'])

        expect(Graph::WorkOrder.find_by(reference: '00000003')).to be_nil
        expect(work_order_1.related).to eq []
        expect(work_order_2.related).to eq []
      end

      it 'raises an exception if the work_order for a note is invalid' do
        expect(Hackney::WorkOrder).to receive(:find).with('00000003').and_raise(HackneyAPI::RepairsClient::RecordNotFoundError)

        expect {
          subject.import_note(note_id: 1,
                              logged_at: today,
                              work_order_reference: '00000003',
                              target_numbers: ['00000002'])
        }.to raise_error(HackneyAPI::RepairsClient::RecordNotFoundError)
      end
    end
  end

  describe '#import_work_order' do
    it 'skips existing work orders' do
      original = work_order_1.property_reference

      subject.import_work_order(work_order_ref: '00000001',
                                property_ref: original.succ,
                                created: :tra_la,
                                target_numbers: :la)

      expect(Graph::WorkOrder.find('00000001').property_reference).to eq original
    end

    it 'creates new work orders' do
      subject.import_work_order(work_order_ref: '00000003',
                                property_ref: '00000123',
                                created: today,
                                target_numbers: [])

      work_order = Graph::WorkOrder.find('00000003')
      expect(work_order.created).to eq today
      expect(work_order.property_reference).to eq '00000123'
      expect(work_order.source).to eq 'test-thingy'
    end

    it 'links work orders referenced in the problem description' do
      subject.import_work_order(work_order_ref: '00000003',
                                property_ref: '00000123',
                                created: today,
                                target_numbers: ['00000002'])

      expect(work_order_2.related.pluck(:reference)).to eq ['00000003']
    end
  end
end
