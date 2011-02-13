module OAuth2::Provider
  module RSpec
    module Macros
      extend ActiveSupport::Concern

      def json_from_response
        @json_from_response ||= begin
          response.content_type.should == Mime::JSON
          Yajl::Parser.new.parse(response.body)
        end
      end

      module ClassMethods
        def responds_with_header(name, value)
          it %{responds with header #{name}: #{value}} do
            response.headers[name].should == value
          end
        end

        def responds_with_status(status)
          it %{responds with status #{status}} do
            response.status.should == status
          end
        end

        def responds_with_json_error(name, options = {})
          it %{responds with json: {"error": "#{name}"}, status: #{options[:status]}} do
            response.status.should == options[:status]
            json_from_response.should == {"error" => name}
          end
        end

        def redirects_back_with_error(name)
          it %{redirects back with error '#{name}'} do
            response.status.should == 302
            error = Addressable::URI.parse(response.location).query_values["error"]
            error.should == name
          end
        end
      end
    end
  end
end