----------------------------------------------------------------
local function data_package(vName, vTimeStartStr, vTimeEndStr, vTimeTaken, vFunctionName, vStatus, vTdata, vEdata)
    vTdata = vTdata or ""
    vEdata = vEdata or ""
    vStatus = tostring(vStatus)

    local t = {"t", vTimeStartStr, "\t", vName, "\t", vFunctionName, "\t"}
    local E = {"E", vTimeStartStr, "\t", vName, "\t", vFunctionName, "\t", vStatus, "\t", vEdata, "\t"}
    local T = {"T", vTimeEndStr, "\t", vName, "\t", vFunctionName, "\t", vStatus, "\t", vTimeTaken, "us", "\t", vTdata, "\t"}

    local data = table.concat( t, "")
    data = data .."\n" ..table.concat(E, "")
    data = data .."\n" ..table.concat(T, "") .."\n"
    return data
end

----------------------------------------------------------------
local function get_times(vMessage)
    --get data for time
    local start_sec     = vMessage.call_start_time_sec
	local start_usec    = vMessage.call_start_time_usec
	local end_sec       = vMessage.call_end_time_sec
	local end_usec      = vMessage.call_end_time_usec
    local use_us            = us_diff(start_sec, start_usec, end_sec, end_usec)
	local start_format_time = format_str_time(start_sec, start_usec)
	local end_format_time   = format_str_time(end_sec, end_usec)

    return start_format_time, end_format_time, use_us
end

----------------------------------------------------------------
local _M = {}
_M.data_package = data_package
_M.get_times    = get_times
return _M

----------------------------------------------------------------
