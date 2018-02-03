require 'rubygems'
require 'bundler/setup'

require 'sqlite3'
require 'date'

require_relative 'linkclass'
require_relative 'dbcalls'

class Feeder

  def initialize(genres, years)
    @genres = genres
    @years = years
  end

  attr_accessor :genres, :years, :list

  def feed

    # Creating an instance variable of feed which consists of an array of 
    # Link objects, which will in a future operation be passed to 
    # Parse::chart_parse_song or Parse::chart_parse_album
    list = []
    @list = list

    # iterating through each genre
    @genres.each do |g|

      # Just one console output per genre
      puts "Building #{g} songs links..."

      # This has nothing to do with the link object, so moving the create table 
      # command here prevents calling it way more times than necessary.
      DBcalls::create_genre_table(g)

      # Iterating through each year
      @years.each do |y|

        # Iterating through each week
        (1...53).each do |w|
          # All operations within the 1...53 loop or else the array push doesn't work.

          # Initializing link object, assigning genre and year.
          link = Link.new
          link.genre = g
          link.year = y.to_i

          # Turning the week and year into date, using the date and genre to
          # build a link with operations from Link class.
          begin
            link.week = w
            link.date_get
            linkdate = link.date_get
            link.url_genre

            # Dealing with future dates
            if linkdate > Date.today + 6
              then
              next
            else
              # Printing date and extra blnak line to make output more readable
              link.url_make
            end

            # This is where each individual link is pushed to the array of links
            # to be used by chart_parse module
            @list << link

          # This rescue is for dealing with the every few years that there is a
          # 53rd Saturday.
          rescue
            puts "#{linkdate} is not a valid date! Moving to the next year..."
            next
          end
        end
      end
    end
  end

  def feed_albums

    # Creating an instance variable of feed which consists of an array of Link 
    # objects, which will in a future operation be passed to 
    # Parse::chart_parse_song or Parse::chart_parse_album
    list = []
    @list = list

    prog_bar = ProgressBar.create(:title => "Links progress",
									   :starting_at => 0,
									   :total => @genres.length * @years.length)

    # iterating through each genre
    @genres.each do |g|

      # Only one output to console for link-building phase
      prog_bar.log "Building #{g} albums links..."

      # This has nothing to do with the link object, so moving the create table 
      # command here prevents calling it way more times than necessary.
      DBcalls::create_album_genre(g)

      # Iterating through each year
      @years.each do |y|

        # Iterating through each week
        (1...53).each do |w|
          # All operations within the 1...53 loop or else the array push doesn't work.

          # Initializing link object, assigning genre and year.
          link = Link.new
          link.genre = g
          link.year = y.to_i

          # Turning the week and year into date, using the date and genre to build a
          # link with operations from Link class.
          begin
            link.week = w
            link.date_get
            linkdate = link.date_get
            link.url_albums

            # Dealing with future dates
            if linkdate > Date.today + 6
            then
              next
            else
              # Printing date and extra blnak line to make output more readable
              link.url_make
            end

            # This is where each individual link is pushed to the array of links to be
            # used by chart_parse module
            @list << link

              # This rescue is for dealing with the every few years that there is
              #  a 53rd Saturday.
          rescue
            prog_bar.log "#{linkdate} is not a valid date! Moving to the next year..."
            next
          end
        end

        prog_bar.increment

      end
    end
  end

end

