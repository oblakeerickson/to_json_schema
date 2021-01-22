# frozen_string_literal: true
require 'json'

module ToJsonSchema
  class Converter

    attr_reader :schema

    def initialize(args)
      @args = args
      @schema = {}
      self.add_defaults
    end

    def print
      puts JSON.pretty_generate(@schema)
    end

    def load_content
      if @args[:input]
        content = self.read_file
      elsif
        content = @args[:string]
      end
    end

    def run
      content = self.load_content
      @schema[:properties], @schema[:required] = walk(content)
    end

    def walk(object)
      required = []
      h = {}
      object.each do |k,v|
        required << k.to_s
        type = get_type(v)
        if type == "object"
          p, r = walk(object[k])
          h[k.to_sym] = {
            type: type,
            properties: p,
            required: r
          }
        elsif type == "array"
          h[k.to_sym] = {
            type: type,
            items: []
          }
        else
          h[k.to_sym] = {
            type: type
          }
        end
      end

      [h, required]
    end

    def get_type(value)
      type = ""
      if value.is_a? Integer
        type = "integer"
      end
      if value.is_a? Hash
        type = "object"
      end
      if value.is_a? String
        type = "string"
      end
      type = "boolean" if value == true || value == false
      if value.is_a? Array
        type = "array"
      end
      type
    end

    def read_file
      JSON.parse(File.read(@args[:input]))
    end

    def add_defaults
      self.add_additional_properties_field
    end

    def add_additional_properties_field
      @schema["additionalProperties"] = false
    end

  end
end
