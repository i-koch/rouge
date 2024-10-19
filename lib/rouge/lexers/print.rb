# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Print < RegexLexer
      title "Prn files"
      desc "A lexer that highlights ScriptPrinter prn files"

      tag 'print'
      aliases 'print'
      filenames '*.prn'
      mimetypes 'text/prn'

      # This lexer is very special, because it highlights a file type which is 
      # company specific. However, I need it for documenting the printer language 
      # with Asciidoc.
      # There is one drawback: The part which contains the text to print doesn't
      # require to be enclosed in double quotes. Therefore numbers found in this
      # text are highlighted as numbers. Only numbers within a string are high-
      # lighted as strings. Although it can be considered as a bug it makes at 
      # least readig the macros clearer ;-)
      printcommands = %w(
        TEXTBOX TEXT 
        BOX HLINE VLINE RECT 
        TDCODE BARCODE QRCODE 
        BACKGROUND BITMAP LOGO SVDDATA
      )

      funcnames = %w(
        IFNOTEMPTY IF LOOKUP 
        COPY REPLACE 
        PADLEFT PADRIGHT TRIMLEFT SUBSTLETTERS
        LENGTHDIFF LENGTH 
        ADD MULTIPLY MODULO 
        TRIMNUM FORMATNUM 
        CALCDATE FORMATDATE AMPM USADATE
      )

      # some general matches
      id = /[äöüa-zA-Z_][äöüa-zA-Z0-9_-]*/
      number = /0|[1-9]\d*/
      # specific matches for the print commands      
      fonts =/ARIAL|TAHOMA|TIMES NEW ROMAN|SANS-SERIF-LIGHT|SANS-SERIF-THIN|SANS-SERIF-CONDENSED|SANS-SERIF|SERIF|MONOSPACE|HELVETICA-NARROW|HELVETICA CONDENSED/i
      fstyle =/:BOLD|:ITALIC|:UNDERLINE/i
      bcpar =/MOD|LEV|ORI|SHOWTEXT|INTERNAL|RATIO|CODE39|CODE128/i
      bcval=/ABOVE|BELOW|NO_TEXT/i
      # a very basic date time format string recognition, not ment for syntax
      # checks but only to find te format strings and highlight them
      dtformat = /(ddd )*([dmhs]{1,2}|y{2,4})[\/\\.-]{0,1}([dmhs]{1,2}|y{2,4})([\/\\.-]{0,1}([dmhs]{1,2}|y{2,4}))*( tt)*/i


      state :comment do
        # a single comment line, check it first to have anything following the // 
        # handled as the comment
        rule %r/[\t ]*\/\/.*/, Comment
      end

      state :special do
        # some special charaters which need our attention
        rule %r/\s+/, Text::Whitespace
        rule %r/=/, Operator
        rule %r/,/, Punctuation
        rule %r/[-\/\(\\]\*/, Str
      end

      state :initline do
        # now for the initlines, every id wstarting with a !
        rule %r/(!#{id})/, Name::Variable
      end

      state :commands do
        # a typical command consists of a pair of x/y coordinates,
        # the command name, some command parameters and
        # finally the text/macro combination to print
        # The text to print is handled in the prnout state
        rule %r/#{number}\.\d+/, Num::Float
        rule %r/#{number}/, Num::Integer
        rule %r/\*/, Str
        rule %r/#{printcommands.join('|')}/i, Keyword
        rule %r/LEFT|RIGHT|CENTER|WRAP/i, Name::Constant
        rule %r/#{fonts}(#{fstyle})*/i, Name::Constant
        rule %r/#{bcpar}/, Name::Constant
        rule %r/#{bcval}/, Name::Constant
      end

      state :prnout do       
        # The text to print may either be a macro beginning with '${' or plain text
        # some special characters have to be recognized too ...
        rule %r/{\$/, Name::Function, :inmacro
        rule %r/#{id}\s*[,\/\(\*]*/, Str
        rule %r/.+/, Str
      end

      state :inmacro do
        # a macro can be either valueXXX or a function with a parameter list
        rule %r/value/i, Name::Function
        rule %r/#{funcnames.join('|')}/i, Name::Function, :inparlist
        rule %r/#{id}/, Name::Variable
        rule %r/=|\+/, Operator
        rule %r/}/, Name::Function, :pop!
      end

      state :inparlist do
        # The parameter list is a bit tricky 
        # parameters start with a '(' and are separated by a '|'.
        # They may either contain an other macro, constant strings, numbers 
        # or format strings. A single string parameter can be combined from 
        # multiple values by concatenating them with a '+'.
        # The parameter list is finished by the first ')' not beeing part 
        # of a string.
        rule %r/#{dtformat}/, Name::Constant
        mixin :inmacro
        rule %r/\(/, Punctuation
        rule %r/"/, Str::Double, :instring
        rule %r/\s+/, Text::Whitespace
        rule %r/value/i, Name::Function
        rule %r/#{id}/, Name::Variable
        rule %r/#{number}/, Num::Integer
        rule %r/=|\+/, Operator
        rule %r/\|/, Punctuation
        rule %r/\)/, Punctuation, :pop!        
      end

      state :instring do
        # strings are quite simple, anything btween two '"' is considered to 
        # be a string
        rule %r/[^"]+/, Str::Double
        rule %r/"/, Str::Double, :pop!
      end

      state :root do
        # first the comments so that they do not interfere with other rules
        mixin :comment
        # then the special chars
        mixin :special
        # and the init lines
        mixin :initline
        # now for the command part
        mixin :commands
        # and finally the text and macros
        mixin :prnout
      end
    end
  end
end
