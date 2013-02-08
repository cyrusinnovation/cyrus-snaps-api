require 'bundler/setup'
require File.expand_path('../lib/cyrus_snaps', __FILE__)

run CyrusSnaps::Server
