# encoding: utf-8
require 'active_model'

module Markun
  # =Markun::DslModel
  class DslModel
    include ActiveModel::Model

    # have menu or not
    attr_accessor :have_menu
  end
end
