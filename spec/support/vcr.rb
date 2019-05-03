require 'vcr'

# Cerealizes jason bodies as jason instead of string
class JasonCerealizer
  def file_extension
    "json"
  end

  def serialize(hash)
    each_jason_message(hash) {|msg| to_jason(msg) }
    JSON.pretty_generate(hash)
  end

  def deserialize(string)
    hash = JSON.parse(string)
    each_jason_message(hash) {|msg| from_jason(msg) }
    hash
  end

  private

  def each_jason_message(hash, &block)
    Enumerator.new do |y|
      hash["http_interactions"].each do |pair|
        pair.each do |direction, message|
          case direction
          when "request", "response"
            if is_jason?(message)
              y << message
            end
          end
        end
      end
    end.each(&block)
  end

  def is_jason?(message)
    message.dig("headers", "Content-Type")&.grep(/json/)
  end

  def to_jason message
    body = message["body"]
    string = body.delete("string")
    body["json"] = JSON.parse(string)
  end

  def from_jason message
    body = message["body"]
    jason = body.delete("json")
    body["string"] = jason.to_json
  end
end

# Cerealizes to convenient webmock format for copy-pasting
class MockCerealizer
  def file_extension
    "rb"
  end

  def serialize(hash)
    hash["http_interactions"].map do |pair|
      request = pair["request"]
      response = pair["response"]
      request_body = body_string(request)
      response_body = body_string(response)
      template = <<~EOF
        stub_request(:<%= request["method"] %>, <%= request["uri"].inspect %>)
        <%- if request["body"]["string"].present? -%>
          .with(body: <%= indent(request_body, 1) %>)
        <%- end -%>
          .to_return(status: <%= response["status"]["code"] %><%- if response["body"]["string"].present? -%>, body: <%= indent(response_body, 1) %><%- end -%>)
      EOF
      ERB.new(template, trim_mode: "%-").result(binding)
    end.join("\n").gsub(/<%=(.*)%>/, '#{\1}')
  end

  def deserialize(string)
    raise "Not supported!"
  end

  private

  def is_jason?(message)
    message.dig("headers", "Content-Type")&.grep(/json/)
  end

  def body_string(message)
    if is_jason?(message)
      jason = JSON.parse(message["body"]["string"])
      JSON.pretty_generate(jason).gsub(": null", ": nil") + ".to_json"
    else
      message["body"]["string"].inspect
    end
  end

  def indent(s, n=1)
    s.each_line.each_with_index.map do |l, i|
      if (i == 1) .. (i == -1) # I'll miss u, Ben </3
        "  " * n + l
      else
        l
      end
    end.join()
  end
end

VCR.configure do |config|
  # Path to store recordings
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.default_cassette_options = {
    match_requests_on: %i(method uri body),
    serialize_with: :rb,
    erb: :true
  }

  # Cerealize with custom jason cerealizer
  config.cassette_serializers[:json] = JasonCerealizer.new
  config.cassette_serializers[:rb] = MockCerealizer.new

  # Use webmock for recording/replaying
  config.hook_into :webmock

  # RSpec
  config.configure_rspec_metadata!

  # ignore calls to localhost and neo4j
  config.ignore_localhost = true
  config.ignore_hosts 'neo4j_db_test'

  # Don't record access tokens!
  config.filter_sensitive_data("<TOKEN>") do |i|
    i.request.headers["X-Api-Key"].first
  end

  # rewrite url with ERB
  config.filter_sensitive_data("<%= ENV['HACKNEY_REPAIRS_API_BASE_URL'] %>") do |i|
    ENV['HACKNEY_REPAIRS_API_BASE_URL']
  end
end
