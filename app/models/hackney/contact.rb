class Hackney::Contact
  include ActiveModel::Model

  attr_accessor :name, :telephone_number, :email_address

  def self.build(attributes)
    new(
      name: attributes['name'],
      telephone_number: attributes['telephoneNumber'],
      email_address: attributes['emailAddress']
    )
  end
end
