# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Rails.configuration.cipher = EasyCipher::Cipher.new(
  AppSettings.secrets.cipher_key,
  AppSettings.secrets.cipher_iv
)
