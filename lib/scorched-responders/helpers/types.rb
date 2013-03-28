module Scorched
  module Responders
    module Helpers
      module Types
        # Returns an array of acceptable media types for the response
        def accept
          env['scorched.accept'] ||= begin
            entries = env['HTTP_ACCEPT'].to_s.scan(Scorched::Responders::AcceptEntry::HEADER_VALUE_WITH_PARAMS)
            entries.map { |e| AcceptEntry.new(e) }.sort
          end
        end

        def preferred_type(*types)
          accepts = accept # just evaluate once
          return accepts.first if types.empty?
          types.flatten!
          return types.first if accepts.empty?
          accepts.detect do |pattern|
            type = types.detect { |t| File.fnmatch(pattern, t) }
            return type if type
          end
        end

        alias accept? preferred_type

        def content_type(type, params={})
          type = Rack::File::MIME_TYPES[type.to_s] if type.kind_of?(Symbol)
          fail "Invalid or undefined media_type: #{type}" if type.nil?
          if params.any?
            params = params.collect { |kv| "%s=%s" % kv }.join(', ')
            type = [ type, params ].join(";")
          end
          response.header['Content-Type'] = type
        end

        def media_type
          preferred_type
        end

        def mime_type(type, value = nil)
          return type      if type.nil?
          return type.to_s if type.to_s.include?('/')
          type = ".#{type}" unless type.to_s[0] == ?.
          return Rack::Mime.mime_type(type, nil) unless value
          Rack::Mime::MIME_TYPES[type] = value
        end
        
        # Will return a short symbol for a full type
        # basically the reverse of mime_type
        #  
        # @example
        #   reverse_mime_type('application/json')
        def reverse_mime_type(type)
          return type if type.nil?
          type = type.to_s
          Rack::Mime::MIME_TYPES.detect { |index, mime| mime == type }.to_a[0].gsub('.', '').to_sym
        end
      end
    end
  end
end
