require 'json'

module ToJsonSchema
  class Converter

    def initialize(args)
      @args = args
      @schema = {}
      self.add_defaults
    end

    def convert
      if @args[:input]
        contents = self.read_file
        puts contents
        contents.keys.each do |k|
          if contents[k].is_a? Hash
            @schema["properties"] = {
              "#{k}": {
                type: "object",
                properties: {}
              }
            }
          end
        end
        puts @schema
        puts @schema.to_json
      end
    end

    def read_file
      JSON.parse(File.read(@args[:input]))
    end

    def add_defaults
      self.add_additional_properties_field
      self.add_properties_field
    end

    def add_additional_properties_field
      @schema["additionalProperties"] = false
    end

    def add_properties_field
      @schema["properties"] = {}
    end

  end
end
