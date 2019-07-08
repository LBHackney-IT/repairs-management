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
      if object.errors.include?(key)
        clazz += " govuk-form-group--error"
      end
      @template.content_tag(:div, class: clazz) do
        yield if block_given?
      end.html_safe
    end

    def label(*args)
      options = args.extract_options!
      options[:class] = "govuk-label " + options[:class].to_s
      args << options
      super
    end

    def text_field(*args)
      options = args.extract_options!
      class_and_error_wrap(args.first, "govuk-input", "govuk-input--error", options)
      args << options
      super
    end

    def text_area(*args)
      options = args.extract_options!
      class_and_error_wrap(args.first, "govuk-textarea", "govuk-textarea--error", options)
      args << options
      super
    end

    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      class_and_error_wrap(method, "govuk-select", "govuk-select--error", html_options)
      super
    end

    def checkboxes_group(&b)
      @template.content_tag(class: "govuk-checkboxes") do
        yield if block_given?
      end.html_safe
    end

    def checkboxes_group_item(&b)
      @template.content_tag(class: "govuk-checkboxes__item") do
        yield if block_given?
      end.html_safe
    end

    def check_box(method, options = {}, *args)
      class_and_error_wrap(method, "govuk-checkboxes__input", "", options)
      super
    end

    def check_box_label(method, text = nil, options = {}, *args)
      class_and_error_wrap(method, "govuk-checkboxes__label", "", options)
      label(method, text, options, *args)
    end

    private

    def class_and_error_wrap(method, clazz, error_clazz, options)
      options[:class] ||= clazz
      options[:class] += " " + error_clazz.to_s if object.errors.include?(method)
      options
    end
  end

  def govuk_form_with(*args, &block)
    options = args.extract_options!
    args << options.merge(builder: GovukFormBuilder)
    form_with(*args, &block)
  end
end
