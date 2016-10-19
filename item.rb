#
# @class  Item 
#
# @brief  Handles various game items
#
class Item

    #
    # Method to initialize the given item object
    #
    def initialize(x, y, type)

        # Set the item coords
        @x = x
        @y = y

        # Default item size is 16x16
        @height = 16
        @length = 16

        # Set the item type
        @type = type
        
        # CDRom is 32x32
        if @type == "compact_disc_01" then
            @height = 32
            @length = 32
        end
       
        # Load the item type sprite 
        @sprite = Gosu::Image.load_tiles($window, 
                                         "img/#{@type.to_s}.png",
                                         @height,
                                         @length,
                                         false)

        # If the player has obtained an item:
        if @type == "flop4" then

            # The got_item.ogg is used here.
            @sound = Gosu::Sample.new($window, "ogg/got_item.ogg")
            @score = 4

        # CDRom sound:
        elsif @type == "compact_disc_01" then

            # The power_up.ogg is used here.
            @sound = Gosu::Sample.new($window, "ogg/power_up.ogg")
            @score = -1
        end    
    end

    #
    # Method to update the item
    #
    def update

    end

    #
    # Method to grab the X coord
    #
    def get_x
        return @x + @sprite[0].width/2
    end

    #
    # Method to grab the Y coord
    #
    def get_y
        return @y + @sprite[0].height/2
    end

    #
    # Method to play the score-increase sound, and update the UI counter
    #
    def get_score

        # Play the requested sound
        @sound.play

        # Return the current score value
        return @score
    end

    # Draw the item at the requested location
    def draw(camera_x, camera_y, z = 1)

        # Use the timestamp milliseconds as the frame limiter
        frame = Gosu::milliseconds / 150 % @sprite.size

        # Use that value to draw the current item sprite frame
        @sprite[frame].draw(@x - camera_x, @y - camera_y, z)
    end

end
