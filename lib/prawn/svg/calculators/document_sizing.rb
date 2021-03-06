module Prawn::Svg::Calculators
  class DocumentSizing
    attr_writer :document_width, :document_height
    attr_writer :view_box, :preserve_aspect_ratio
    attr_writer :requested_width, :requested_height

    attr_reader :x_offset, :y_offset, :x_scale, :y_scale
    attr_reader :viewport_width, :viewport_height, :output_width, :output_height

    def initialize(bounds, attributes = nil)
      @bounds = bounds
      set_from_attributes(attributes) if attributes
    end

    def set_from_attributes(attributes)
      @document_width = attributes['width']
      @document_height = attributes['height']
      @view_box = attributes['viewBox']
      @preserve_aspect_ratio = attributes['preserveAspectRatio']
    end

    def calculate
      @x_offset = @y_offset = 0
      @x_scale = @y_scale = 1

      width = Prawn::Svg::Calculators::Pixels.to_pixels(@document_width, @bounds[0])
      height = Prawn::Svg::Calculators::Pixels.to_pixels(@document_height, @bounds[1])

      default_aspect_ratio = "x#{width ? "Mid" : "Min"}Y#{height ? "Mid" : "Min"} meet"

      width ||= @bounds[0]
      height ||= @bounds[1]

      if @view_box
        values = @view_box.strip.split(/\s+/)
        @x_offset, @y_offset, @viewport_width, @viewport_height = values.map {|value| value.to_f}
        @x_offset = -@x_offset

        @preserve_aspect_ratio ||= default_aspect_ratio
        aspect = Prawn::Svg::Calculators::AspectRatio.new(@preserve_aspect_ratio, [width, height], [@viewport_width, @viewport_height])
        @x_scale = aspect.width / @viewport_width
        @y_scale = aspect.height / @viewport_height
        @x_offset -= aspect.x
        @y_offset -= aspect.y
      end

      @viewport_width ||= width
      @viewport_height ||= height

      if @requested_width
        scale = @requested_width / width
        width = @requested_width
        height *= scale
        @x_scale *= scale
        @y_scale *= scale

      elsif @requested_height
        scale = @requested_height / height
        height = @requested_height
        width *= scale
        @x_scale *= scale
        @y_scale *= scale
      end

      @output_width = width
      @output_height = height

      self
    end
  end
end
