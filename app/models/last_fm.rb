module LastFM
  class Base
    include HTTParty
    include Hashie

    base_uri 'http://ws.audioscrobbler.com/2.0/'
    headers "user-agent" => Headbang::USER_AGENT
    # debug_output $stderr

    class_attribute :api_key
    self.api_key = "84324111ccccaa831f917ca14114bd6e"

    class << self
      def request(path, opts = {})
        response = get(path, query: opts.reverse_merge(format: "json", api_key: api_key))
        case response.response
          when Net::HTTPOK
            Hashie::Mash.new(response)
          else
            raise ArgumentError, response.parsed_response
        end
      end
    end
  end

  class Album < Base
    class << self
      def search(args = {})
        request '/', args.merge(method: "album.getinfo")
      end
    end
  end
end
