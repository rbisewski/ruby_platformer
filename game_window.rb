#
# @class  GameWindow
#
# @brief  Wrapper class that implements Gosu::Window
#
class GameWindow < Gosu::Window

    # 
    # Method to define the basic window attributes
    #
    def initialize
       
        # Set the screen size
        super(630,470,false)

        # Assign a title to the window.
        self.caption = "Sample Ruby Platformer Game"

        # Internal ref
        $window = self

        # Give the window a map and text layer.
        $scene = Level.new
        $text = GameFont.new
    end
    
    #
    # Method to update this window
    #
    def update
        $scene.update
    end
    
    #
    # Method used to draw this window
    #
    def draw
        $scene.draw
    end
    
    #
    # Method used for handling button presses.
    #
    def button_down(id)
        $scene.button_down(id)
    end
    
    #
    # Method used for handling button releases.
    #
    def button_up(id)
        $scene.button_up(id)
    end

end
