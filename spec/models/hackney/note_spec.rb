require 'rails_helper'

describe Hackney::Note do
  def stub_get_notes
    stub_request(:get, "https://hackneyrepairs/v1/work_orders/01551932/notes")
      .to_return(status: 200,
        body: [{
          "text": "Tenant called to confirm appointment",
          "loggedAt": "2018-08-23T10:12:56+01:00",
          "loggedBy": "MOSHEA",
          "noteId": 3000
        }].to_json)
  end

  describe '.for_work_order' do
    it 'returns a response' do
      stub_get_notes
      response = Hackney::Note.for_work_order('01551932')

      expect(response.first.text).to eq('Tenant called to confirm appointment')
      expect(response.first.logged_by).to eq('MOSHEA')
      expect(response.first.note_id).to eq(3000)
    end
  end

  def stub_post_a_note
    stub_request(:post, "https://hackneyrepairs/v1/notes").with(
      headers: {
        "Content-Type" => "application/json-patch+json"
      },
      body: {"objectKey": "uhorder",
        "objectReference": "01234567",
        "text": "This is a note",
        "lbhemail": "Celia"
      }.to_json
    ).to_return(
      status: 200,
      body: {
        "text": "This is a note",
        "loggedAt": "2019-06-10 12:39:51 +0100",
        "loggedBy": "Celia",
        "noteId": 3000,
        "workOrderReference": "01234567"
        }.to_json
      )
  end

  describe '.create_work_order_note' do
    it 'creates a note' do
      stub_post_a_note

      note_response = Hackney::Note.create_work_order_note(
        "01234567", "This is a note", "Celia"
      )

      note = Hackney::Note.build(note_response)

      expect(note.text).to eq("This is a note")
      expect(note.logged_by).to eq("Celia")
      expect(note.note_id).to eq(3000)
    end
  end
end
