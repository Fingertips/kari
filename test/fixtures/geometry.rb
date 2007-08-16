# This is a bogus module to use as a source file to seed the RI YAML files for the indexing and searching tests.
module Geometry

  # Point describes a point in a two dimensional space.
  class Point
    attr_accessor :x, :y

    # Create a new Point instance with the specified coordinates.
    def initialize(x, y)
      @x, @y = x, y
    end
  end

  # Square describes a square in a two dimensional space.
  class Square
    attr_accessor :origin, :width, :height

    # Create a new Square instance.
    #
    # Parameters:
    #   * <tt>origin</tt>: An instance of Point describing the upper left corner.
    #   * <tt>width</tt>: The width of the Square, should be numeric.
    #   * <tt>height</tt>: The height of the Square, should be numeric.
    #
    # Example:
    #   square = Square.new(Point.new(12, 12), 120, 240)
    def initialize(origin, width, height)
      @origin, @width, @height = origin, width, height
    end

    # Flips width and height, thus rotating it.
    def rotate
      @width, @height = @height, @width
    end
  end

  # Defaults for the various parameters
  module Defaults
    ORIGIN = Point.new(0, 0)
    X = 0
    Y = 0
  end
end