require 'indirizzo/constants'

module Indirizzo
  # Defines the matching of parsed address tokens.
  Match = {
    # FIXME: shouldn't have to anchor :number and :zip at start/end
    :number   => /^(\d+\W|[a-z]+)?(\d+)([a-z]?)\b/io,
    :street   => /(?:\b(?:\d+\w*|[a-z'-]+)\s*)+/io,
    :city     => /(?:\b[a-z][a-z'-]+\s*)+/io,
    :state    => State.regexp,
    :zip      => /\b(\d{5})(?:-(\d{4}))?\b/o,
    :at       => /\s(at|@|and|&)\s/io,
    :po_box => /\b[P|p]*(OST|ost)*\.*\s*[O|o|0]*(ffice|FFICE)*\.*\s*[B|b][O|o|0][X|x]\b/
  }

  # The Address class takes a US street address or place name and
  # constructs a list of possible structured parses of the address
  # string.
  class Address
    attr_accessor :text
    attr_accessor :prenum, :number, :sufnum
    attr_accessor :street
    attr_accessor :city
    attr_accessor :state
    attr_accessor :zip, :plus4
    attr_accessor :country
    attr_accessor :options

    # Takes an address or place name string as its sole argument.
    def initialize (text, options={})
      @options = {:expand_streets => true}.merge(options)

      raise ArgumentError, "no text provided" unless text and !text.empty?
      if text.class == Hash
        @text = ""
        assign_text_to_address text
      else
        @text = clean text
        parse
      end
    end

    # Removes any characters that aren't strictly part of an address string.
    def clean (value)
      value.strip \
           .gsub(/[^a-z0-9 ,'&@\/-]+/io, "") \
           .gsub(/\s+/o, " ")
    end

    def assign_text_to_address(text)
      if !text[:address].nil?
        @text = clean text[:address]
        parse
      else
        @street = []
        @prenum = text[:prenum]
        @sufnum = text[:sufnum]
        if !text[:street].nil?
          @street = text[:street].scan(Match[:street])
        end
        @number = ""
        if !@street.nil?
          if text[:number].nil?
            @street.map! { |single_street|
              single_street.downcase!
              @number = single_street.scan(Match[:number])[0].reject{|n| n.nil? || n.empty?}.first.to_s
              single_street.sub! @number, ""
              single_street.sub! /^\s*,?\s*/o, ""
            }
          else
            @number = text[:number].to_s
          end
          @street = expand_streets(@street) if @options[:expand_streets]
          street_parts
        end
        @city = []
        if !text[:city].nil?
          @city.push(text[:city])
          @text = text[:city].to_s
        else
          @city.push("")
        end
        if !text[:region].nil?
          # @state = []
          @state = text[:region]
          if @state.length > 2
            # full_state = @state.strip # special case: New York
            @state = State[@state]
          end
        elsif !text[:state].nil?
          @state = text[:state]
        elsif !text[:country].nil?
          @state = text[:country]
        end

        @zip = text[:postal_code]
        @plus4 = text[:plus4]
        if !@zip
          @zip = @plus4 = ""
        end
      end
    end

    # Expands a token into a list of possible strings based on
    # the Geocoder::US::Name_Abbr constant, and expands numerals and
    # number words into their possible equivalents.
    def expand_numbers (string)
      if /\b\d+(?:st|nd|rd|th)?\b/o.match string
        match = $&
        num = $&.to_i
      elsif Ordinals.regexp.match string
        num = Ordinals[$&]
        match = $&
      elsif Cardinals.regexp.match string
        num = Cardinals[$&]
        match = $&
      end
      strings = []
      if num and num < 100
        [num.to_s, Ordinals[num], Cardinals[num]].each {|replace|
          strings << string.sub(match, replace)
        }
      else
        strings << string
      end
      strings
    end

    def parse_state(regex_match, text)
      idx = text.rindex(regex_match)
      @full_state = @state[0].strip # special case: New York
      @state = State[@full_state]
      @city = "Washington" if @state == "DC" && text[idx...idx+regex_match.length] =~ /washington\s+d\.?c\.?/i
      text
    end

    def parse
      text = @text.clone.downcase

      @zip = text.scan(Match[:zip]).last
      if @zip
        last_match = $&
        zip_index = text.rindex(last_match)
        zip_end_index = zip_index + last_match.length - 1
        @zip, @plus4 = @zip.map {|s| s and s.strip }
      else
        @zip = @plus4 = ""
        zip_index = text.length
        zip_end_index = -1
      end

      @country = @text[zip_end_index+1..-1].sub(/^\s*,\s*/, '').strip
      @country = nil if @country == text

      @state = text.scan(Match[:state]).last
      if @state
        last_match = $&
        state_index = text.rindex(last_match)
        text = parse_state(last_match, text)
      else
        @full_state = ""
        @state = ""
      end

      @number = text.scan(Match[:number]).first
      # FIXME: 230 Fish And Game Rd, Hudson NY 12534
      if @number # and not intersection?
        last_match = $&
        number_index = text.index(last_match)
        number_end_index = number_index + last_match.length - 1
        @prenum, @number, @sufnum = @number.map {|s| s and s.strip}
      else
        number_end_index = -1
        @prenum = @number = @sufnum = ""
      end

      # FIXME: special case: Name_Abbr gets a bit aggressive
      # about replacing St with Saint. exceptional case:
      # Sault Ste. Marie

      # FIXME: PO Box should geocode to ZIP
      street_search_end_index = [state_index,zip_index,text.length].reject(&:nil?).min-1
      @street = text[number_end_index+1..street_search_end_index].scan(Match[:street]).map { |s| s and s.strip }

      @street = expand_streets(@street) if @options[:expand_streets]
      # SPECIAL CASE: 1600 Pennsylvania 20050
      @street << @full_state if @street.empty? and @state.downcase != @full_state.downcase

      street_end_index = @street.map { |s| text.rindex(s) }.reject(&:nil?).min||0

      if @city.nil? || @city.empty?
        @city = text[street_end_index..street_search_end_index+1].scan(Match[:city])
        if !@city.empty?
          #@city = [@city[-1].strip]
          @city = [@city.last.strip]
          add = @city.map {|item| item.gsub(Name_Abbr.regexp) {|m| Name_Abbr[m]}}
          @city |= add
          @city.map! {|s| s.downcase}
          @city.uniq!
        else
          @city = []
        end

        # SPECIAL CASE: no city, but a state with the same name. e.g. "New York"
        @city << @full_state if @state.downcase != @full_state.downcase
      end

    end

    def expand_streets(street)
      if !street.empty? && !street[0].nil?
        street.map! {|s|s.strip}
        add = street.map {|item| item.gsub(Name_Abbr.regexp) {|m| Name_Abbr[m]}}
        street |= add
        add = street.map {|item| item.gsub(Std_Abbr.regexp) {|m| Std_Abbr[m]}}
        street |= add
        street.map! {|item| expand_numbers(item)}
        street.flatten!
        street.map! {|s| s.downcase}
        street.uniq!
      else
        street = []
      end
      street
    end

    def street_parts
      strings = []
      # Get all the substrings delimited by whitespace
      @street.each {|string|
        tokens = string.split(" ")
        strings |= (0...tokens.length).map {|i|
                   (i...tokens.length).map {|j| tokens[i..j].join(" ")}}.flatten
      }
      strings = remove_noise_words(strings)

      # Try a simpler case of adding the @number in case everything is an abbr.
      strings += [@number] if strings.all? {|s| Std_Abbr.key? s or Name_Abbr.key? s}
      strings.uniq
    end

    def remove_noise_words(strings)
      # Don't return strings that consist solely of abbreviations.
      # NOTE: Is this a micro-optimization that has edge cases that will break?
      # Answer: Yes, it breaks on simple things like "Prairie St" or "Front St"
      prefix = Regexp.new("^" + Prefix_Type.regexp.source + "\s*", Regexp::IGNORECASE)
      suffix = Regexp.new("\s*" + Suffix_Type.regexp.source + "$", Regexp::IGNORECASE)
      predxn = Regexp.new("^" + Directional.regexp.source + "\s*", Regexp::IGNORECASE)
      sufdxn = Regexp.new("\s*" + Directional.regexp.source + "$", Regexp::IGNORECASE)
      good_strings = strings.map {|s|
        s = s.clone
        s.gsub!(predxn, "")
        s.gsub!(sufdxn, "")
        s.gsub!(prefix, "")
        s.gsub!(suffix, "")
        s
      }
      good_strings.reject! {|s| s.empty?}
      strings = good_strings if !good_strings.empty? {|s| not Std_Abbr.key?(s) and not Name_Abbr.key?(s)}
      strings
    end

    def city_parts
      strings = []
      @city.map do |string|
        tokens = string.split(" ")
        strings |= (0...tokens.length).to_a.reverse.map {|i|
                   (i...tokens.length).map {|j| tokens[i..j].join(" ")}}.flatten
      end
      # Don't return strings that consist solely of abbreviations.
      # NOTE: Is this a micro-optimization that has edge cases that will break?
      # Answer: Yes, it breaks on "Prairie"
      strings.reject { |s| Std_Abbr.key?(s) }.uniq
    end

    def city= (strings)
      # NOTE: This will still fail on: 100 Broome St, 33333 (if 33333 is
      # Broome, MT or what)
      strings = expand_streets(strings) # fix for "Mountain View" -> "Mountain Vw"
      match = Regexp.new('\s*\b(?:' + strings.join("|") + ')\b\s*$', Regexp::IGNORECASE)
      @street = @street.map {|string| string.gsub(match, '')}.select {|s|!s.empty?}
    end

    def po_box?
      !Match[:po_box].match(@text).nil?
    end

    def intersection?
      !Match[:at].match(@text).nil?
    end
  end
end
