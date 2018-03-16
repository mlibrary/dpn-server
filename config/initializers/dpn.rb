# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

Rails.application.configure do
  cfg = config_for(:dpn)
  config.local_namespace  = cfg["local_namespace"]
  config.local_api_root   = cfg["local_api_root"]
  config.staging_dir      = cfg["staging_dir"]
  config.repo_dir         = cfg["repo_dir"]
  config.active_job.queue_adapter = cfg["queue_adapter"]
end
