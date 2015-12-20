require 'sunspot'
require 'sunspot/rails'

# == Examples:
#
# class Post
#   include Neo4j::ActiveNode
#   field :title
#
#   include Sunspot::Neo4j
#   searchable do
#     text :title
#   end
# end
#
module Sunspot
    module Neo4j
        def self.included(base)
            base.class_eval do
            extend Sunspot::Rails::Searchable::ActsAsMethods
            extend Sunspot::Neo4j::ActsAsMethods
            Sunspot::Adapters::DataAccessor.register(DataAccessor, base)
            Sunspot::Adapters::InstanceAdapter.register(InstanceAdapter, base)
        end
    end

    module ActsAsMethods
        # ClassMethods isn't loaded until searchable is called so we need
        # call it, then extend our own ClassMethods.
        def searchable(opt = {}, &block)
            super
            extend ClassMethods
        end
    end

    module ClassMethods
        # The sunspot solr_index method is very dependent on ActiveRecord, so
        # we'll change it to work more efficiently with Mongoid.
        def solr_index(opt={})
            Sunspot.index!(all)
        end
    end

    class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
      def id
        @instance.id
      end
    end

    class DataAccessor < Sunspot::Adapters::DataAccessor
      def load(id)
        criteria(id).first
      end

      def load_all(ids)
        criteria(ids)
      end

      private

      def criteria(id)
        @clazz.find(id)
      end
    end
  end
end