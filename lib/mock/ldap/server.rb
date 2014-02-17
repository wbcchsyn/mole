require 'socket'
require 'logger'
require 'openssl'

require 'mock/ldap/asn1'
require 'mock/ldap/worker'

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
          @logger = Logger.ne(args[:log])
        else
          @logger = Logger.new($stdout)
        end

        if args[:level]
          case args[:level].to_s.upcase
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
          class << sock
            include Mock::Ldap::Asn1::IO
          end

          loop do
            receive = OpenSSL::ASN1.decode(sock.fetch_ber)
            request, response = Mock::Ldap::Worker.handle(receive)
            send = response.to_pdu

            send.each do |pdu|
              sock.write(pdu.to_der)
            end


            @logger.info("Receive: #{request.protocol}.")
            @logger.debug(Asn1::pp_pdu(receive))

            if response.result == :success
              @logger.info("Send: #{response.diagnostic_message}")
            else
              @logger.warn("Send: #{response.diagnostic_message}")
            end
            send.each do |pdu|
              @logger.debug(Asn1::pp_pdu(pdu))
            end

          end

        rescue Errno::EBADF
          # When @gsock is closed while running
          # Do nothing

        rescue
          @logger.error($!.message)
          $!.backtrace.each do |line|
            @logger.error(line)
          end

        ensure
          sock.close if sock
        end
      end

      def close
        @gsock.close
      end

      def clear
        Worker.clear
      end

    end
  end
end
