#
# @class  GameFont 
#
# @brief  Handles the font object and its utilization
#
class GameFont < Gosu::Font

    #
    # Method to initialize the font object
    #
    def initialize
        @font = Gosu::Font.new($window, "fonts/eight_bit.ttf", 20)
    end

    #
    # Method to render the font on-screen 
    #
    def draw_text(text, x, y, z, scale_x = 1.0, scale_y = 1.0, 
                  color = Gosu::Color.new(255,255,255), mode = :default)

        # Draw the font at the requested location
        @font.draw(text,
                   x,
                   y,
                   z,
                   scale_x = 1.0,
                   scale_y = 1.0,
                   color = Gosu::Color.new(0,255,255),
                   mode = :default)
    end

end
