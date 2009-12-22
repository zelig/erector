module Erector
  module Rails
    module Helpers
      include ActionController::UrlWriter

      # parent returning raw text whose first parameter is HTML escaped
      ESCAPED_HELPERS = [
        :link_to,
        :link_to_remote,
        :mail_to,
        :button_to,
        :submit_tag,
      ]
      ESCAPED_HELPERS.each do |method_name|
        module_eval(<<-METHOD_DEF, __FILE__, __LINE__)
          def #{method_name}(link_text, *args, &block)
            rawtext(helpers.#{method_name}(h(link_text), *args, &block))
          end
        METHOD_DEF
      end

      # return text, take block
      RAW_HELPERS = [
        :link_to_function,
        :text_field_tag,
        :password_field_tag,
        :check_box_tag,
        :error_messages_for,
        :submit_tag,
        :file_field,
        :image_tag,
        :javascript_include_tag,
        :stylesheet_link_tag,
        :sortable_element,
        :sortable_element_js,
        :text_field_with_auto_complete
      ]
      RAW_HELPERS.each do |method_name|
        module_eval(<<-METHOD_DEF, __FILE__, __LINE__)
          def #{method_name}(*args, &block)
            rawtext helpers.#{method_name}(*args, &block)
          end
        METHOD_DEF
      end

      CAPTURED_HELPERS_WITHOUT_CONCAT = [
        :render
      ]
      CAPTURED_HELPERS_WITHOUT_CONCAT.each do |method_name|
        module_eval(<<-METHOD_DEF, __FILE__, __LINE__)
          def #{method_name}(*args, &block)
            captured = helpers.capture do
              helpers.concat(helpers.#{method_name}(*args, &block))
              helpers.output_buffer.to_s
            end
            rawtext(captured)
          end
        METHOD_DEF
      end

      CAPTURED_HELPERS_WITH_CONCAT = [
        :form_tag
      ]
      CAPTURED_HELPERS_WITH_CONCAT.each do |method_name|
        module_eval(<<-METHOD_DEF, __FILE__, __LINE__)
          def #{method_name}(*args, &block)
            captured = helpers.capture do
              helpers.#{method_name}(*args, &block)
              helpers.output_buffer.to_s
            end
            rawtext(captured)
          end
        METHOD_DEF
      end

      def form_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        options[:builder] ||= ::Erector::RailsFormBuilder
        args.push(options)
        helpers.form_for(record_or_name_or_array, *args, &proc)
      end

      def fields_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        options[:builder] ||= ::Erector::RailsFormBuilder
        args.push(options)
        helpers.fields_for(record_or_name_or_array, *args, &proc)
      end
      
      DIRECTLY_DELEGATED = [
        :url_for,
        :javascript_include_merged,
        :stylesheet_link_merged,
        :controller,
        :cycle,
        :time_ago_in_words,
        :pluralize,
        :image_path
      ]
      
      DIRECTLY_DELEGATED.each do |method_name|
        module_eval(<<-METHOD_DEF, __FILE__, __LINE__)
          def #{method_name}(*args, &block)
            helpers.#{method_name}(*args, &block)
          end
        METHOD_DEF
      end
      
      def flash
        helpers.controller.send(:flash)
      end

      def session
        helpers.controller.session
      end
    end

    Erector::Widget.send :include, Helpers
  end
end
