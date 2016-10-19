#
# Description: A sample platformer written in ruby and gosu.
#
# How-To: Run `ruby main.rb` from the console
#

$: << File.dirname(__FILE__)

# Gem requires.
require 'csv'
require 'gosu'
require 'rubygems'

# Game requires.
require "game_font.rb"
require "game_window.rb"
require "item.rb"
require "level.rb"
require "protagonist.rb"

# Debug mode (0 is disabled and 1 is enabled)
$debug_mode = 0

# Initialize the basic game window.
$window = GameWindow.new
$window.show
