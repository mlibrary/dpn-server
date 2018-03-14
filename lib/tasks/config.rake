# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

namespace :config do

  desc "Generate cipher iv, key"
  task :cipher do
    cipher = EasyCipher::Cipher.new
    puts "key: #{cipher.key64.inspect}"
    puts "iv: #{cipher.iv64.inspect}"
  end

end

