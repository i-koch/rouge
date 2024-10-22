# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::Docsample do
  let(:subject) { Rouge::Lexers::Docsample.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => '*.docsample'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-docsample'
    end
  end
end
