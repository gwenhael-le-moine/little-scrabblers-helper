#!/usr/bin/env ruby
# Author: Gwenhael Le Moine
# Date: 2011.04.10
# Description: lookup possible words formed from supplied letters (includeing '.' jokers) in dictionary given

def hash( word )
   word.chomp.split( '' ).sort.join.downcase
end

def load_dict( dictfile )
   dict = Hash.new( [  ] )
   if File.exist?( "#{dictfile}_hash" ) then
      File.open( "#{dictfile}_hash", "r" ) do |file|
         dict = Marshal.load( file )
      end
   else
      File.open( dictfile, "r" ) do |file|
         while line = file.gets
            dict[ hash( line ) ] += [ line.chomp.downcase ]
         end
      end
      File.open("#{dictfile}_hash", "w") do |file|
         Marshal.dump( dict, file )
      end
   end
   return dict
end

def lookup( word, dict )
   result = [  ]
   if word.index( '.' ) == nil then
      result.concat( dict[ hash( word ) ] )
   else
      ("a".."z").map do |letter|
         result.concat( lookup( word.sub( '.', letter ), dict ) )
      end
   end
   return result.sort
end

if __FILE__ == $0
   require 'readline'

   # handle  gracefully
   stty_save = `stty -g`.chomp

   dict = "dummy"
   if ARGF.argv.size != 0 then
      ARGF.argv.each do
         dictfile = ARGF.argv.pop
         dict = load_dict( dictfile )
      end
   else
      puts "No dictionary given"
      exit 1
   end

   begin
      while line = Readline.readline('letters: ', true)
         p lookup( line, dict )
      end
   rescue Interrupt => e
      # handle  gracefully
      system('stty', stty_save)
      exit 0
   end
end
