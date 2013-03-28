module Scorched 
  module Responders
    # Ported From Sinatra
    class AcceptEntry
      HEADER_PARAM = /\s*[\w.]+=(?:[\w.]+|"(?:[^"\\]|\\.)*")?\s*/
      HEADER_VALUE_WITH_PARAMS = /(?:(?:\w+|\*)\/(?:\w+(?:\.|\-|\+)?|\*)*)\s*(?:;#{HEADER_PARAM})*/
      attr_accessor :params

      def initialize(entry)
        params = entry.scan(HEADER_PARAM).map do |s|
          key, value = s.strip.split('=', 2)
          value = value[1..-2].gsub(/\\(.)/, '\1') if value.start_with?('"')
          [key, value]
        end

        @entry  = entry
        @type   = entry[/[^;]+/].delete(' ')
        @params = Hash[params]
        @q      = @params.delete('q') { "1.0" }.to_f
      end

      def <=>(other)
        other.priority <=> self.priority
      end

      def priority
        # We sort in descending order; better matches should be higher.
        [ @q, -@type.count('*'), @params.size ]
      end

      def to_str
        @type
      end

      def to_s(full = false)
        full ? entry : to_str
      end

      def respond_to?(*args)
        super or to_str.respond_to?(*args)
      end

      def method_missing(*args, &block)
        to_str.send(*args, &block)
      end
    end
  end
end
