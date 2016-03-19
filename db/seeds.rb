require_relative '../update'

Version.create(number: "0000") if Version.count == 0
refresh_ids
