puts 'Load files'

require 'active_support/core_ext'
# avoid i18n deprecation warning [BS]
I18n.enforce_available_locales = false

require 'time_range/time_range_splitter'
require 'time_range/time_range_covered_range'
require 'time_range/time_range_overlaps'
require 'time_range/time_range_uniter'
require 'time_range/time_range'
