# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Docsample < RegexLexer
      title "docsample"
      desc 'the configuration documentation format'
      tag 'docsample'

      # TODO add more here
      filenames '*.docsample'
      mimetypes 'text/x-docsample'

      # some bqasic defnitions
      alpha = /[a-zA-Z]/
      alphanum = /[a-zA-Z0-9]/
      number = /(0|[1-9])\d*/

      # The identifier of a config variable
      nameid = /[\w\-.]+/
      # and the value of that variable which can contain a lot of things
      valuestr = /[\w\_\[\],-\/\:\(\'\!)]+/     

      state :basic do
        rule %r/\s*[;#].*?\n/, Comment
        rule %r/\s+/, Text
        rule %r/\\\n/, Str::Escape
      end

      state :root do
        mixin :basic
        rule %r/^\s*(#{nameid})(\s*)(=)/ do
          groups Name::Property, Text, Operator
          push :value
        end
      end

      state :value do
        # EOL? value is finished
        rule %r/\n\n/, Text, :pop!
        # one of the fix values? 
        rule %r/(yes|no|ask|keep)(?!#{alphanum})/i, Keyword, :pop!
        # a modulo rule to prevent the leading nubers to be recognized as such
        rule %r/(10|11|97)[A-Z]+/, Str
        # Numbers
        rule %r/#{number}/, Num::Integer

        rule %r/#{valuestr}/, Str      
        rule %r/\s+/, Text
        rule %r/=|\|/, Operator
      end

    end
  end
end
