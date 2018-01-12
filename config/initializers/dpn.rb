# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

Rails.application.configure do
  config.local_namespace  = AppSettings.dpn.local_namespace
  config.local_api_root   = AppSettings.dpn.local_api_root
  config.staging_dir      = AppSettings.dpn.staging_dir
  config.repo_dir         = AppSettings.dpn.repo_dir
  config.active_job.queue_adapter = AppSettings.dpn.queue_adapter
end
