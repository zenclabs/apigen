# frozen_string_literal: true

require_relative '../util'
require_relative './endpoint'
require_relative '../models/registry'

module Apigen
  ##
  # Rest contains what you need to declare a REST-ish API.
  module Rest
    ##
    # Declares an API.
    def self.api(&block)
      api = Api.new
      raise 'You must a block when calling `api`.' unless block_given?
      api.instance_eval(&block)
      api.validate
      api
    end

    ##
    # Api is a self-contained definition of a REST API, includings its endpoints and data types.
    class Api
      attr_reader :endpoints
      attribute_setter_getter :description

      def initialize
        @description = ''
        @endpoints = []
        @model_registry = Apigen::ModelRegistry.new
      end

      ##
      # Declares a specific endpoint.
      def endpoint(name, &block)
        error = if @endpoints.find { |e| e.name == name }
                  "Endpoint :#{name} is declared twice."
                elsif !block_given?
                  'You must pass a block when calling `endpoint`.'
                end
        raise error unless error.nil?
        endpoint = Endpoint.new name
        @endpoints << endpoint
        endpoint.instance_eval(&block)
      end

      ##
      # Declares a data model.
      def model(name, &block)
        @model_registry.model name, &block
      end

      def models
        @model_registry.models
      end

      def validate
        @model_registry.validate
        @endpoints.each do |e|
          e.validate @model_registry
        end
      end

      def migrate(*migration_classes)
        migration_classes.each { |klass| klass.new(self).up }
        validate
      end

      def to_s
        repr = "Endpoints:\n\n"
        repr += @endpoints.map(&:to_s).join "\n"
        repr += "\nTypes:\n\n"
        repr += @model_registry.to_s
        repr
      end
    end
  end
end
