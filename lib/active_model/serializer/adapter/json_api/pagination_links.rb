module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        class PaginationLinks
          FIRST_PAGE = 1

          attr_reader :collection, :options

          def initialize(collection, options={})
            raise_unless_any_gem_installed
            @collection = collection
            @options = options
          end

          def page_links
            pages_from.each_with_object({}) do |(key, value), hash|
              params = query_parameters.merge(page: { number: value, size: collection.size }).to_query
              hash[key] = "#{url}?#{params}"
            end
          end

          private

          def pages_from
            return {} if collection.total_pages == FIRST_PAGE

            {}.tap do |pages|
              unless collection.current_page == FIRST_PAGE
                pages[:first] = FIRST_PAGE
                pages[:prev]  = collection.current_page - FIRST_PAGE
              end

              unless collection.current_page == collection.total_pages
                pages[:next] = collection.current_page + FIRST_PAGE
                pages[:last] = collection.total_pages
              end
            end
          end

          def raise_unless_any_gem_installed
            return if defined?(WillPaginate) || defined?(Kaminari)
            raise "AMS relies on either Kaminari or WillPaginate." +
              "Please install either dependency by adding one of those to your Gemfile"
          end

          def url
            return default_url unless options && options[:links] && options[:links][:self]
            options[:links][:self]
          end

          def default_url
            options[:original_url]
          end

          def query_parameters
            options[:query_parameters] ? options[:query_parameters] : {}
          end
        end
      end
    end
  end
end
