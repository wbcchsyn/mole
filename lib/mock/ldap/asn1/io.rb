module Mock
  module Ldap
    module Asn1

      #
      # IO mix-in module
      #
      # This module allows to read ber string from nonblocking IO instance.
      #
      module IO

        #
        # Read a sequence of ber string from IO
        #
        # [Return]
        #   Ber String encoded 'ASCII-8BIT'
        #
        def fetch_ber
          ber = fetch_ber_identifier

          if ber.bytes[0] == 0x00 # EOC
            return ber
          end

          length, byte = fetch_ber_length
          ber << byte

          if length
            ber << read_exact_bytes(length)
          else
            # Indefinite length
            begin
              _ber = fetch_ber
              ber << _ber
            end until _ber.bytes[0] == 0x00 # EOC
            ber
          end
        end

        private

        def read_exact_bytes(size)
          bytes = ''
          bytes.encode!('ASCII-8BIT')

          while bytes.length < size
            buf = read(size - bytes.length)
            raise Errno::EBADF unless buf
            bytes << buf
          end

          raise "Assertion." unless bytes.length == size

          bytes
        end

        def fetch_ber_identifier
          identifier = read_exact_bytes(1)

          if (identifier.bytes[0] & 0x1f) == 0x1f
            # long form
            begin
              _next = read_exact_bytes(1)
              identifier << _next
            end until (_next.bytes[0] & 0x80) == 0
          end

          identifier
        end

        #
        # Read necessary bytes from socket and parse ber length
        #
        # [Return]
        #   \[<ber length>, <ASCII-8BIT string to be red>\]
        #
        def fetch_ber_length
          head = read_exact_bytes(1)
          head_byte = head.bytes[0]

          if head_byte == 0x80
            # Indefinite length
            [nil, head]

          elsif (head_byte & 0x80) == 0x00
            # Short form
            [head_byte, head]

          else
            # Long form
            tail_length = (head_byte & 0x7f)
            tail = read_exact_bytes(tail_length)

            length = tail.bytes.reduce(0) do |acc, byte|
              (acc << 8) | byte
            end

            [length, (head + tail)]
          end
        end
      end

    end
  end
end
