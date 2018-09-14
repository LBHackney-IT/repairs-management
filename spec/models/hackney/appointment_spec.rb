require 'rails_helper'

describe Hackney::Appointment do
  include Helpers::HackneyRepairsRequestStubs

  describe '.build' do
    let(:attributes) do
      {
        'id'=> '01551945',
        'status'=> 'completed',
        'assignedWorker'=> '(PLM) Tom Sabin Unboxed',
        'phonenumber'=> '+44 mobile',
        'priority'=> 'standard',
        'sourceSystem'=> 'DRS',
        'comment'=> 'FIRST',
        'creationDate'=> '2018-05-31T15:05:51',
        'beginDate'=> '2018-05-31T08:00:00',
        'endDate'=> '2018-05-31T16:15:00'
      }
    end

    subject { described_class.build(attributes) }

    it 'builds when the API response contains all fields' do
      expect(subject).to be_a(Hackney::Appointment)
      expect(subject.end_date).to eq(DateTime.new(2018, 05, 31, 16, 15, 00))
      expect(subject.begin_date).to eq(DateTime.new(2018, 05, 31, 8, 00, 00))
      expect(subject.reported_on).to eq(DateTime.new(2018, 05, 31, 15, 5, 51))
      expect(subject.comment).to eq('FIRST')
      expect(subject.phone_number).to eq('+44 mobile')
      expect(subject.assigned_worker).to eq('(PLM) Tom Sabin Unboxed')
      expect(subject.priority).to eq('standard')
      expect(subject.status).to eq('completed')
    end
  end

  describe '.latest_for_work_order' do
    let(:reference) { 'ref' }
    let(:response) { {} }
    let(:api_client_double) { instance_double(HackneyAPI::RepairsClient, get_work_order_appointments_latest: response) }
    let(:appointment_double) { instance_double(described_class) }

    subject { described_class.latest_for_work_order(reference) }

    before do
      allow(HackneyAPI::RepairsClient).to receive(:new).and_return(api_client_double)
    end

    context 'successful API response - latest appointment exists' do
      it 'calls API client with a reference number and builds an instance of a class with valid attributes' do
        expect(api_client_double).to receive(:get_work_order_appointments_latest).with(reference)
        expect(described_class).to receive(:build).with(response).and_return(appointment_double)
        expect(subject).to eq(appointment_double)
      end
    end

    context 'not found API response - latest appointment does not exist' do
      before do
        allow(api_client_double).to receive(:get_work_order_appointments_latest).with(reference).and_raise(HackneyAPI::RepairsClient::RecordNotFoundError)
      end

      it 'calls API client with a reference nunmber and returns nil' do
        expect(subject).to eq(nil)
      end
    end
  end

  describe '.all_for_work_order' do
    context 'successful API response' do
      stub_hackney_repairs_work_order_appointments

      appointments = described_class.all_for_work_order('01551932')

      expect(appointments.count).to eq(3)
    end
  end
end
