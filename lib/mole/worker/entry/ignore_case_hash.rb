module Mole
  module Worker
    module Entry


      class IgnoreCaseHash < Hash

        def has_key?(key)
          keys.any? do |k|
            k =~ /^#{key}$/i
          end
        end

        def [](key)
          each_pair do |k, v|
            return v if k =~ /^#{key}$/i
          end

          nil
        end

        def []=(key, value)
          delete(key)
          super
        end

        def delete(key)
          keys.each do |k|
            return super(k) if k =~ /^#{key}$/i
          end
          nil
        end
      end

      private_constant :IgnoreCaseHash


    end
  end
end
