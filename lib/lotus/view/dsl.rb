require 'lotus/utils/string'
require 'lotus/view/rendering/layout_finder'

module Lotus
  module View
    # Class level DSL
    #
    # @since 0.1.0
    module Dsl
      # When a value is given, specify a templates root path for the view.
      # Otherwise, it returns templates root path.
      #
      # When not initialized, it will return the global value from `Lotus::View.root`.
      #
      # @param value [String] the templates root for this view
      #
      # @return [Pathname] the specified root for this view or the global value
      #
      # @since 0.1.0
      #
      # @example Default usage
      #   require 'lotus/view'
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #     end
      #   end
      #
      #   Lotus::View.root    # => 'app/templates'
      #   Articles::Show.root # => 'app/templates'
      #
      # @example Custom root
      #   require 'lotus/view'
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #       root 'path/to/articles/templates'
      #     end
      #   end
      #
      #   Lotus::View.root    # => 'app/templates'
      #   Articles::Show.root # => 'path/to/articles/templates'
      def root(value = nil)
        if value
          @@root = Pathname.new value
        else
          @@root ||= Lotus::View.root
        end
      end

      # When a value is given, specify the handled format.
      # Otherwise, it returns the previously specified format.
      #
      # @param value [Symbol] the format
      #
      # @return [Symbol, nil] the specified format for this view, if set
      #
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/view'
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #     end
      #   end
      #
      #   Articles::Show.format     # => nil
      #   Articles::JsonShow.format # => :json
      def format(value = nil)
        if value
          @format = value
        else
          @format
        end
      end

      # When a value is given, specify the relative path to the template.
      # Otherwise, it returns the name that follows Lotus::View conventions.
      #
      # @param value [String] relative template path
      #
      # @return [String] the specified template for this view or the name
      #   that follows the convention
      #
      # @since 0.1.0
      #
      # @example Default usage
      #   require 'lotus/view'
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #     end
      #   end
      #
      #   Articles::Show.template     # => 'articles/show'
      #   Articles::JsonShow.template # => 'articles/show'
      #
      # @example Custom template
      #   require 'lotus/view'
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #       template 'articles/single_article'
      #     end
      #
      #     class JsonShow < Show
      #       format :json
      #     end
      #   end
      #
      #   Articles::Show.template     # => 'articles/single_article'
      #   Articles::JsonShow.template # => 'articles/single_article'
      def template(value = nil)
        if value
          @@template = value
        else
          @@template ||= Utils::String.new(name).underscore
        end
      end

      # When a value is given, it specifies the layout.
      # Otherwise, it returns the previously specified layout.
      #
      # When the global configuration is set (`Lotus::View.layout=`), after the
      # loading process, it will return that layout if not otherwise specified.
      #
      # @param value [Symbol,nil] the layout name
      #
      # @return [Symbol, nil] the specified layout for this view, if set
      #
      # @since 0.1.0
      #
      # @see Lotus::Layout
      #
      # @example Default usage
      #   require 'lotus/view'
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #     end
      #   end
      #
      #   Articles::Show.layout # => nil
      #
      # @example Custom layout
      #   require 'lotus/view'
      #
      #   class ArticlesLayout
      #     include Lotus::Layout
      #   end
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #       layout :articles
      #     end
      #   end
      #
      #   Articles::Show.layout # => :articles
      #
      # @example Global configuration
      #   require 'lotus/view'
      #
      #   class ApplicationLayout
      #     include Lotus::Layout
      #   end
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #     end
      #   end
      #
      #   Lotus::View.layout = :application
      #   Articles::Show.layout # => nil
      #
      #   Lotus::View.load!
      #   Articles::Show.layout # => :application
      #
      # @example Global configuration with custom layout
      #   require 'lotus/view'
      #
      #   class ApplicationLayout
      #     include Lotus::Layout
      #   end
      #
      #   class ArticlesLayout
      #     include Lotus::Layout
      #   end
      #
      #   module Articles
      #     class Show
      #       include Lotus::View
      #       layout :articles
      #     end
      #   end
      #
      #   Lotus::View.layout = :application
      #   Articles::Show.layout # => :articles
      #
      #   Lotus::View.load!
      #   Articles::Show.layout # => :articles
      def layout(value = nil)
        if value
          @layout = value
        else
          @layout
        end
      end

      protected

      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::View.load!
      def load!
        super

        views.each do |v|
          v.root.freeze
          v.format.freeze
          v.template.freeze
          v.layout(Rendering::LayoutFinder.new(v).find)
          v.layout.freeze
        end
      end
    end
  end
end
