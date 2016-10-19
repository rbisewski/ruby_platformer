#
# @class  Level 
#
# @brief  Handle the game levels
#
class Level

    #
    # Method to initialize the level map
    #
    def initialize

        # First determine which tileset is need by this level by reading the
        # config file for that level
        $tmp_file = File.open('maps/level_one.cfg')

        # Attempt to convert the file contents to a string
        @used_tileset = String.try_convert($tmp_file.read)

        # Go ahead and close the file
        $tmp_file.close

        # Sanity check, make certain the file read was successful
        if @used_tileset == nil then
            print "Error: Unable to read level config contents!\n"
            exit
        end

        # Clean up white spaces
        @used_tileset = @used_tileset.chomp

        # Sanity check, make sure this still has contents
        if @used_tileset == nil then
            print "Error: Unable to read level config contents!\n"
            exit
        end

        # Secondly, grab the level tile location data and read it in to an
        # array of integers.
        @level_surface_tiles = CSV.read('maps/level_one.surface', {converters: :numeric})
        @level_hidden_tiles = CSV.read('maps/level_one.hidden', {converters: :numeric})
        
        # Sanity check, make sure the file could be read.
        if @level_surface_tiles == nil then
            print "Error: Unable to read level surface contents!\n"
            exit
        end
        if @level_hidden_tiles == nil then
            print "Error: Unable to read level hidden contents!\n"
            exit
        end

        # Assemble the level array
        @level = [@level_surface_tiles, @level_hidden_tiles]

        # Thirdly, obtain the object coord data.
        @objects = CSV.read('maps/level_one.objects')

        # Sanity check, make sure the file could be read.
        if @objects == nil then
            print "Error: Unable to read level config contents!\n"
            exit
        end

        # Tileset is 16x16 chunks with tileable
        @tileset = Gosu::Image::load_tiles(@used_tileset,
                                           16,
                                           16,
                                           {:tileable => true})

        # Variable to hold the tile data
        @tile_data = []

        # Grab data from the pass file
        data_raw = File.read("#{@used_tileset}.pass")

        # Scan the raw data for numbers and get them
        pass = data_raw.scan(/\d+/)

        # Slice up the tile image into a collection of tiles
        @tile_data = pass.collect! &:to_i

        # Initialize the player variable
        @player = nil

        # Load all the needed entities into memory
        @entities = []
        load_entities

        # Variable to hold the camera location
        @camera_x = 0
        @camera_y = 0

        # Variable to hold the hidden tiles array
        @hidden_tiles = []

        # Variable to hold the current score
        @score = 0
    end

    #
    # Method to load the entities
    #
    def load_entities

        # Cycle thru the list of objects
        for i in 0...@objects.size

            # Handle each type differently
            case @objects[i][0]

            # Player character, so initialize a Protagonist object
            when "player"

                # Generate the protagonist start location
                @player = Protagonist.new(@objects[i][1].to_f, @objects[i][2].to_f)

                # Debug mode, tell the developer what was added.
                if $debug_mode == 1 then
                    print "load_entities() --> [ player,",
                          @objects[i][1].to_f,
                          ",",
                          @objects[i][2].to_f,
                          "]\n"
                end

            # Otherwise probably an item, so initialize an Item object
            when "flop4", "compact_disc_01"

                # Add the item to the list of entities
                @entities << Item.new(@objects[i][1].to_f, @objects[i][2].to_f, @objects[i][0])

                # Debug mode, tell the developer what was added.
                if $debug_mode == 1 then
                    print "load_entities() --> [ ",
                          @objects[i][0],
                          ",",
                          @objects[i][1].to_f,
                          ",",
                          @objects[i][2].to_f,
                          "]\n"
                end
            end
        end
    end

    #
    # Method to update the screen
    #
    def update

        # Left-Arrow button pressed
        if $window.button_down?(Gosu::KbLeft) then

            # Sanity check, make sure this can grab the needed tile
            if ![1,2].include?(get_tile_info(@player.get_x,
                                             @player.get_y,
                                             :left)) then

                # Call the move_left function
                @player.move_left

            end
        end

        # Right-Arrow button pressed
        if $window.button_down?(Gosu::KbRight) then

            # Sanity check, make sure this can grab the needed tile
            if ![1,2].include?(get_tile_info(@player.get_x,
                                             @player.get_y,
                                             :right)) then

                # Call the move_right function
                @player.move_right

            end 
        end

        # Update the player object
        @player.update

        # Functionalize the list of entities
        @entities.each{|en| 
            en.update

            # Compare the player coords with the entity coords, in the event
            # the player has reached an item / entity location
            dist = Gosu::distance(@player.get_x,
                                  @player.get_y(:center),
                                  en.get_x,
                                  en.get_y)

            # Player closely approaches an entity...
            if dist < 20 then

                # get_score() returns a -1 in the event of invulnerability
                if en.get_score < 0 then
                    @player.invulnerable
                    @entities.delete(en)

                # Otherwise add this to the score and remove the item from
                # the map
                else
                    @score += en.get_score
                    @entities.delete(en)
                end
            end
        }

        # Handle the player falling when the down sprite is being used
        if [0,2,4].include?(get_tile_info(@player.get_x, @player.get_y,:down)) then

            # Call the fall() routine
            @player.fall 

            # Handle the player respawn event
            if get_tile_info(@player.get_x, @player.get_y,:down) == 4 then
                @player.respawn
            end

        # Otherwise the the acceleration back to 0, since the player has
        # safely hit the ground
        else
            @player.reset_acceleration
        end

        # While jumping, move the player upwards
        while ![0,2].include?(get_tile_info(@player.get_x,
                                            @player.get_y - 1,
                                            :down)) do

            # Call the move_up() function
            @player.move_up
        end

        # Check if the player is current jumping
        if @player.is_jumping? then

            # Determine if the up sprite is being used
            if get_tile_info(@player.get_x, @player.get_y,:up) != 0 then

                # In which case, reset the jump event, since it has
                # already occurred
                @player.reset_jump
            end
        end

        # Check if the player is "down and facing right"
        if get_tile_info(@player.get_x, @player.get_y,:down) == 5 then
            @player.slide_left

        # Check if the player is "down and facing left"
        elsif get_tile_info(@player.get_x, @player.get_y,:down) == 6 then
            @player.slide_right
        end

        # Check if the player is inside of a hidden location
        if in_hidden_entrance then

            # Initialize the hidden tiles array
            @hidden_tiles = []

            # Cycle thru the y coords ...
            for y in 0...@level[1].size

                # ... and the x coords
                for x in 0...@level[1][y].size

                    # Set the current X / Y coords
                    curx = (x * 16) + 8
                    cury = (y * 16) + 8

                    # Determine the distance between the player and the
                    # current location
                    dist = Gosu::distance(@player.get_x,
                                          @player.get_y(:center),
                                          curx,
                                          cury)

                    # Append the current location to the hidden tiles array
                    if dist < 32 then
                        @hidden_tiles << [x,y]
                    end
                end
            end

        # Empty the hidden tiles array since the player is not in a hidden
        # location
        else
            @hidden_tiles = []
        end

        # Set the camera coords
        @camera_x = [[@player.get_x - 320, 0].max,
                      @level[0][0].size * 16 - 640].min

        @camera_y = [[@player.get_y - 240, 0].max,
                      @level[0].size * 16 - 480].min
    end

    #
    # Method to handle the hidden location entrance event
    #
    def in_hidden_entrance

        # Determine the tile placement, as integers 
        tile_x = (@player.get_x/16).to_i
        tile_y = (@player.get_y/16).to_i

        # Hidden tile is present, so return true
        if @level[1][tile_y-1][tile_x] > 0 then
            return true

        # Otherwise the player is no longer hidden
        else
            return false
        end
    end

    #
    # Method to grab the tile data
    #
    def get_tile_info(x, y, pos=:down)

        # Get the tile location data, as integers
        tile_x = (x/16).to_i
        tile_y = (y/16).to_i

        # Sprite position; default is :down which does nothing
        case pos

        # Up sprite
        when :up
            tile_y -= 2

        # Right sprite
        when :right
            tile_x += 1
            tile_y -= 1

        # Left sprite
        when :left
            tile_x -= 1
            tile_y -= 1
        end

        # Sometimes gosu segfaults the map if outside of the given range,
        # so enforce a respawn to prevent larger issues.
        if tile_y < -45 then
            tile_y = 0
            @player.respawn
        end

        # Print player tile location in debug mode
        if $debug_mode == 1 then
            print "get_tile_info() --> [ ", tile_x, ":", tile_y, "]\n"
        end

        # Use the determined integer location to get the needed tile data
        return @tile_data[@level[0][tile_y][tile_x]]
    end

    #
    # Method to draw the player / entities / camera
    #
    def draw

        # Attach the camera location to the player
        @player.draw(@camera_x, @camera_y,1)

        # Cycle thru each map level...
        for l in 0...@level.size

            # ... and cycle thru each y coord ...
            for y in 0...@level[l].size
 
                # ... and cycle thru each x coord
                for x in 0...@level[l][y].size

                    # Check if this is the first level
                    if l == 1 then

                        # If this is a hidden tile location...
                        if @hidden_tiles.include?([x,y]) then
                            @tileset[@level[l][y][x]].draw((x*16)-@camera_x,
                                     (y*16)-@camera_y,
                                     l+1,
                                     1,
                                     1,
                                     Gosu::Color.new(160,255,255,255))

                        # Otherwise just a normal location
                        else
                            @tileset[@level[l][y][x]].draw((x*16)-@camera_x,
                                                           (y*16)-@camera_y,
                                                           l+1)
                        end

                    # Otherwise just default to the start location
                    else
                        @tileset[@level[l][y][x]].draw((x*16)-@camera_x,
                                                       (y*16)-@camera_y,
                                                       l+1)
                    end
                end
            end
        end

        # For the given camera location, draw all entites present in that
        # location
        @entities.each{|en| en.draw(@camera_x, @camera_y)}

        # Draw the score counter onto the game window
        $text.draw_text("< #{@score} >", 16, 16, 10)
    end

    #
    # Method for when a key is pressed down
    #
    def button_down(id)

        # Up-Arrow key
        if id == Gosu::KbUp then

            # Check if the player sprite can jump
            if [1,3,4,5,6].include?(get_tile_info(@player.get_x,
                                                  @player.get_y,:down)) then

                # Call the jump function
                @player.jump

            # Player still might have a chance to "double" jump
            elsif @player.get_fall < 5 then
                @player.jump
            end
        end
    end

    #
    # Method for when a key is released up
    #
    def button_up(id)

        # Up-Arrow key
        if id == Gosu::KbUp then
            @player.reset_jump if @player.is_jumping?
        end
    end

end
