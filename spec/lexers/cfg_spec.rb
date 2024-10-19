# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::Cfg do
  let(:subject) { Rouge::Lexers::Cfg.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'setup.cfg'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/x-cfg'
    end
  end
end
