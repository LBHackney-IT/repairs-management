module GovukFormHelper
  class GovukFormBuilder < ActionView::Helpers::FormBuilder
    def error_messages(key)
      object.errors[key].map do |msg|
        @template.content_tag(:span, class: "govuk-error-message") do
          @template.content_tag(:span, "Error:", class: "govuk-visually-hidden") + @template.sanitize(msg)
        end
      end.join.html_safe
    end

    def form_group(key, &b)
      clazz = "govuk-form-group"
      if object.errors[key].any? || object.try(key).try(:invalid?)
        clazz += " govuk-form-group--error"
      end
      @template.content_tag(:div, class: clazz) do
        yield if block_given?
      end.html_safe
    end

    def label(*args)
      options = args.extract_options!
      args << options.merge(class: "govuk-label")
      super
    end

    def text_field(*args)
      options = args.extract_options!
      args << options.merge(class: "govuk-input")
      super
    end

    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      html_options[:class] ||= "govuk-input"
      super
    end
  end

  def govuk_form_with(*args, &block)
    options = args.extract_options!
    args << options.merge(builder: GovukFormBuilder)
    form_with(*args, &block)
  end
end
