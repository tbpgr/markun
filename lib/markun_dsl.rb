# encoding: utf-8
require 'markun_dsl_model'

module Markun
  # =Markun::Dsl
  class Dsl
    attr_accessor :markun

    # String Define
    [:have_menu].each do |f|
      define_method f do |value|
        eval "@markun.#{f.to_s} = '#{value}'", binding
      end
    end

    # Array/Hash Define
    [].each do |f|
      define_method f do |value|
        eval "@markun.#{f.to_s} = #{value}", binding
      end
    end

    def initialize
      @markun = Markun::DslModel.new
      @markun.have_menu = 'false'
    end
  end
end
