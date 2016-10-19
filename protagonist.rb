#
# @class  Protagonist 
#
# @brief  Handles the motion and location of the main character
#
class Protagonist 

    #
    # Method to initialize the player character
    #
    def initialize(x,y)

        # Define the current coords
        @real_x = x
        @real_y = y

        # Define the spawn location
        @spawn_x = x
        @spawn_y = y

        # Define the images used to animate the PC when he idles
        @stand_right = Gosu::Image.load_tiles($window, "img/protagonist_idle_right.png", 32, 32, false)
        @stand_left = Gosu::Image.load_tiles($window, "img/protagonist_idle_left.png", 32, 32, false)

        # Define the images used to animate the PC when he walks
        @walk_left = Gosu::Image.load_tiles($window, "img/protagonist_walk_left.png", 32, 32, false)
        @walk_right = Gosu::Image.load_tiles($window, "img/protagonist_walk_right.png", 32, 32, false)

        # Define the images used to animate the PC when he jumps
        @jump_left = Gosu::Image.load_tiles($window, "img/protagonist_jump_left.png", 32, 32, false)
        @jump_right = Gosu::Image.load_tiles($window, "img/protagonist_jump_right.png", 32, 32, false)

        # The sound that is played when the PC jumps
        @jump_sound = Gosu::Sample.new($window, "ogg/jump.ogg")

        # The starting image is direction -> :right
        @sprite = @stand_right
        @dir = :right

        # Using the sprite width / height, calculate the coords
        @x = @real_x + (@sprite[0].width / 2)
        @y = @real_y + @sprite[0].height

        # Motion variables
        @move_x = 0
        @moving = false

        # Jump variables
        @jump = 0

        # Variable to detect the current speed
        @v_acc = 1
        @max_v_acc = 15

        # Variable to determine whether the player is invulnerable or not
        @invulnerability = 0

        # Variable that stores the player's current colour
        @color_alter = 255

        # Variable to check whether the player is falling
        @fall = 0
    end

    #
    # Method to update when a key is pressed
    #
    def update

        # Determine the current coords
        @real_x = @x - (@sprite[0].width / 2)
        @real_y = @y - @sprite[0].height

        # If the player is moving, do this.
        if @moving then

            # Moving left
            if @move_x > 0 then
                @move_x -= 1
                @x += 3

            # Moving right
            elsif @move_x < 0 then
                @move_x += 1
                @x -= 3

            # Somehow this ended up being basically stationary,
            # ergo assume the moving has ceased.
            elsif @move_x == 0 then
                @moving = false
            end

        # Otherwise the player is stationary, so do this
        else

            # Currently left
            if @dir == :left then
                @sprite = @stand_left

            # Currently right
            elsif @dir == :right then
                @sprite = @stand_right
            end
        end

        # If the player is current jumping
        if @jump > 0 then

              # Adjust the current velocity
              @y -= @v_acc
              @v_acc = @v_acc * 0.75

              # Facing left
              if @dir == :left then
                  @sprite = @jump_left

              # Facing right
              elsif @dir == :right then
                  @sprite = @jump_right
              end

              # Since the player can "double jump" this needs to
              # reduce the count by one
              @jump -= 1
        end

       # Invulnerable? Then adjust the colour and mode
        if @invulnerability > 0 then

            # Adjust the colour
            @color_alter += 0.3

            # Change invulnerable mode
            @invulnerability -= 1
        end
    end

    # 
    # Method to adjust the invulnerability
    #
    def invulnerable
        @invulnerability = 300
        @color_alter = 165
    end

    #
    # Method to move the player upwards
    #
    def move_up
        @y -= 1
    end

    #
    # Method to determine whether the player is falling
    #
    def get_fall
        return @fall
    end

    #
    # Method to determine whether the player is jumping
    #
    def is_jumping?
        return @jump > 0
    end

    #
    # Method to end the jump animation
    #
    def reset_jump
        @jump = 0
        @v_acc = 1
    end

    #
    # Method to handle the player when jumping left
    #
    def slide_left
        @x -= Gosu::random(3,5)
        @y -= Gosu::random(1,4)
        @dir = :left
        @sprite = @jump_left
    end

    #
    # Method to handle the player when jumping left
    #
    def slide_right
        @x += Gosu::random(3,5)
        @y -= Gosu::random(1,4)
        @dir = :right
        @sprite = @jump_right
    end

    #
    # Method to respawn the player in the event of death
    #
    def respawn

        # Invulnerable? Then return...
        return if @invulnerability > 0

        # Adjust the real coords back to the spawn point
        @real_x = @spawn_x 
        @real_y = @spawn_y 

        # Adjust the image coords to reflect the fact the player has respawned
        @x = @real_x + (@sprite[0].width / 2)
        @y = @real_y + @sprite[0].height

        # Call the invulnerable routine to handle that situation
        invulnerable
    end

    #
    # Method to reset / end the falling velocity acceleration
    #
    def reset_acceleration
        @v_acc = 1
        @fall = 0
    end

    #
    # Method to handle how the player character falls
    #
    def fall

        # Not jumping?
        if @jump == 0 then

            # Adjust velocity
            @y += @v_acc
            @v_acc = @v_acc * 1.25

            # Cap the velocity to the pre-defined maximum
            @v_acc = @max_v_acc if @v_acc > @max_v_acc

            # Facing left
            if @dir == :left then
                @sprite = @jump_left

            # Facing right
            elsif @dir == :right then
                @sprite = @jump_right
            end

            # Increment the fall state
            @fall += 1
        end
    end

    #
    # Method to handle how the player character jumps
    #
    def jump

        # Sanity check, make sure the player hasn't been falling for awhile
        return if @fall > 50

        # Play the jump sound
        @jump_sound.play

        # Set the jump state
        @jump = 12 if @jump == 0

        # Set the acceleration since the player might be falling, etc
        @v_acc = 20
    end

    #
    # Method to handle how the player moves left
    #
    def move_left
        @dir = :left
        @move_x = -3
        @sprite = @walk_left if @jump == 0
        @moving = true
    end

    #
    # Method to handle how the player moves right
    #
    def move_right
        @dir = :right
        @move_x = 3
        @sprite = @walk_right if @jump == 0
        @moving = true
    end

    #
    # Method to grab the X coord
    #
    def get_x
        return @x
    end

    #
    # Method to grab the Y coord
    #
    def get_y(arg = nil)

        # Return Y is the player is not currently centred
        return @y if arg == nil

        # Otherwise attempt to figure out whether the player is based on
        # the sprite location
        return @real_y + @sprite[0].height / 2 if arg == :center
    end

    #
    # Method to handle how the player sprite is drawn
    #
    def draw(camera_x, camera_y, z=5)

        # Determine the current frame based on the timestamp milliseconds
        frame = Gosu::milliseconds / 90 % @sprite.size

        # Use the coords to draw the player in the proper location
        @sprite[frame].draw(@real_x - camera_x,
                            @real_y - camera_y,
                            z,
                            1.0,
                            1.0,
                            Gosu::Color.new(@color_alter,
                                            @color_alter,
                                            @color_alter,
                                            @color_alter))

        # If invulnerable, draw a simple bar to cue the player as to how
        # long the effect lasts
        if @invulnerability > 0 then

            # Set the width of the bar
            bar_width = (32 * @invulnerability) / 300

            # Grab the window, and draw a simple colour red->green rectangle.
            $window.draw_quad(@real_x - camera_x,
                              @real_y - camera_y - 4,
                              Gosu::Color.new(0,35,35),
                              @real_x - camera_x + bar_width,
                              @real_y - camera_y - 4,
                              Gosu::Color.new(135,0,135),
                              @real_x - camera_x + bar_width,
                              @real_y - camera_y,
                              Gosu::Color.new(135,0,135),
                              @real_x - camera_x,
                              @real_y - camera_y,
                              Gosu::Color.new(0,35,35),
                              z)
        end
    end

end
