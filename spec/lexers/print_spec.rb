# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::Print do
  let(:subject) { Rouge::Lexers::Print.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'foo.prn'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-prn'
    end
  end
end
