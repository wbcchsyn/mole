require 'socket'
require 'logger'


module Mock
  module Ldap


    class Server

      def initialize args={}
        if args[:host]
          raise TypeError, "Optional argument :host is requested to be String." unless args[:host].is_a?(String)
          host = args[:host]
        else
          host = '127.0.0.1'
        end

        if args[:port]
          raise TypeError, "Optional argument :host is requested to be Fixnum." unless args[:port].is_a?(Fixnum)
          port = args[:port]
        else
          port = 3890
        end

        if args[:log]
          @logger = Logger.new(args[:log])
        else
          @logger = Logger.new($stdout)
        end

        if args[:level]
          case args[:logger].to_s.upcase
          when 'DEBUG'
            @logger.level = Logger::DEBUG
          when 'INFO'
            @logger.level = Logger::INFO
          when 'WARN'
            @logger.level = Logger::WARN
          when 'ERROR'
            @logger.level = Logger::ERROR
          when 'FATAL'
            @logger.level = Logger::FATAL
          else
            raise ArgumentError, "Optional argument :level is requested to be debug or info or warn or error or fatal."
          end
        else
          @logger.level = Logger::INFO
        end

        @gsock = TCPServer.open(host, port)
      end

      def listen async=true
        if async
          return Thread.new {
            listen async=false
          }
        end

        until @gsock.closed?
          run
        end
      end

      def run
        sock = nil

        begin
          sock = @gsock.accept
          while char = sock.read(1)
            puts char.bytes[0]
          end

        rescue Errno::BEADF
          # When @gsock is closed while running
          # Do nothing

        rescue
          @logger.error($!.message)
          $!.backtrace.each do |line|
            $logger.error(line)
          end

        ensure
          sock.close if sock
        end
      end

      def close
        @gsock.close
      end

    end


  end
end
