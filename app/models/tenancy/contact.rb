class Tenancy::Contact < Tenancy::Resource
  # FIXME: must always CGI.escape() the :tenancy_id as it contains a slash and
  # is passed into the URL. Maybe active_resource should be escaping this
  # properly but certainly the API shouldn't be using such problematic
  # identifiers
  self.prefix = "#{site.path}/tenancies/:tenancy_id/"

  schema do
    string :full_name
    string :telephone1
    string :telephone2
    string :telephone3
  end
end
