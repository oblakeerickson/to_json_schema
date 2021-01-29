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
      else
        content = self.read_string
      end
    end

    def run
      content = self.load_content
      if content.is_a? Array
        @schema.delete("additionalProperties")
        @schema[:type] = "array"
        @schema[:minItems] = 1
        @schema[:uniqItems] = true
        @schema[:items] = { type: "object" }
        @schema[:items][:properties], @schema[:items][:required] = walk(content[0])
      else # Object
        @schema[:properties], @schema[:required] = walk(content)
      end
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
            additionalProperties: false,
            properties: p,
            required: r
          }
        elsif type == "array"
          item = object[k].first
          if item.is_a? Hash
            p, r = walk(item)
            h[k.to_sym] = {
              type: type,
              items: [
                {
                  type: "object",
                  additionalProperties: false,
                  properties: p,
                  required: r
                }
              ]
            }
          else
            h[k.to_sym] = {
              type: type,
              items: []
            }
          end
        elsif type == "null"
          # null is not a valid OAS3 type
          h[k.to_sym] = {
            type: ["string", "null"]
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
      type = "integer" if value.is_a? Integer
      type = "object" if value.is_a? Hash
      type = "string" if value.is_a? String
      type = "boolean" if value == true || value == false
      type = "array" if value.is_a? Array
      type = "null" if value == nil
      type
    end

    def read_string
      JSON.parse(@args[:string])
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
