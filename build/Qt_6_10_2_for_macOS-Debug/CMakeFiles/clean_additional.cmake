# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appSmartInventory_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appSmartInventory_autogen.dir/ParseCache.txt"
  "appSmartInventory_autogen"
  )
endif()
