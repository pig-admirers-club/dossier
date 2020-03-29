module Dossier
  class ValidationError < StandardError
    attr_accessor :errors
    def initialize(errors)
      @errors = errors
      super "Invalid Fields"
    end
  end

  class Validator
    attr_reader :schema
    attr_accessor :errors

    def initialize(schema)
      schema[:required] = [] unless (schema[:required]&.length&.> 0)
      schema[:match] = [] unless (schema[:match]&.length&.> 0)
      schema[:custom] = [] unless (schema[:custom]&.length&.> 0)

      @schema = schema
      @errors = []
    end

    def add_required_rule(field, message)
      schema[:required] << { field: field, message: message }
    end

    def add_match_rule(field, message, regex)
      schema[:match] << { field: field, message: message, regex: regex }
    end

    def add_custom_rule(field, message, &block) 
      schema[:custom] << {
        field: field,
        message: message,
        condition: block
      }
    end

    def validate(object)
      schema[:required].each do |field_schema|
        if object[field_schema[:field]].nil?
          errors << { field: field_schema[:field], message: field_schema[:message] }
        end
      end

      schema[:match].each do |field_schema|
        result = field_schema[:regex] =~ object[field_schema[:field]].to_s
        errors << { field: field_schema[:field], message: field_schema[:message] } unless result
      end


      schema[:custom].each do |field_schema|
        result = field_schema[:condition].call(object)
        errors.concat field_schema[:fields].map { |field| { field: field, message: field_schema[:message ] }} unless result
      end

      if errors.length > 0
        errs = JSON.parse(errors.to_json)
        @errors = []
        puts @errors, errs
        raise ValidationError.new(errs)
      end
    end
  end
end