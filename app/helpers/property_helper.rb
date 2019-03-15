module PropertyHelper
  def format_postcode(s)
    s.to_s.gsub(/\s+/, "").upcase
  end

  def is_postcode?(s)
    format_postcode(s)[/^[A-Z]{1,2}([0-9]{1,2}|[0-9][A-Z])[0-9][A-Z]{2}$/]
  end
end
