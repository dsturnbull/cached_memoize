require 'active_support/core_ext/object/metaclass'
require 'active_support/core_ext/module/aliasing'
# FIXME include ActiveSupport::Memoizable in this and only define cached_memoize

module ActiveSupport
  module CachedMemoize
    include ActiveSupport::CoreExtensions::Module
    def cached_memoize(*symbols)
      options   = symbols.pop if symbols.last.is_a?(Hash)
      options ||= {}
      options[:expires_in] ||= 1.minute

      symbols.each do |symbol|
        original_method = :"_unmemoized_#{symbol}"
        memoized_ivar = ActiveSupport::Memoizable.memoized_ivar_for(symbol)

        class_eval <<-EOS, __FILE__, __LINE__ + 1
          if method_defined?(:#{original_method})
            raise "Already memoized #{symbol}"
          end
          alias #{original_method} #{symbol}

          if instance_method(:#{symbol}).arity == 0
            def #{symbol}(reload = false)
              found   = Rails.cache.read("#{memoized_ivar}") 
              found ||= Rails.cache.write("#{memoized_ivar}", #{original_method}, :expires_in => #{options[:expires_in]})
              Rails.cache.read("#{memoized_ivar}") 
            end
          else
            def #{symbol}(*args)
              #{memoized_ivar} ||= {} unless frozen?
              reload = args.pop if args.last == true || args.last == :reload

              if defined?(#{memoized_ivar}) && #{memoized_ivar}
                if !reload && #{memoized_ivar}.has_key?(args)
                  Rails.cache.write(#{memoized_ivar}[args])
                  #{memoized_ivar}[args]
                elsif #{memoized_ivar}
                  #{memoized_ivar}[args] = #{original_method}(*args)
                end
              else
                #{original_method}(*args)
              end
            end
          end

          if private_method_defined?(#{original_method.inspect})
            private #{symbol.inspect}
          end
        EOS
      end
    end
  end
end
