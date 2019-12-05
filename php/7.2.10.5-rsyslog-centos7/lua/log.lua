local _M={}
-----------------------------------------------------------------------------------
local log_level={
    STDERR=1,
    EMERG=2,
    ALERT=4,
    CRIT=8,
    ERR=16,
    WARN=32,
    NOTICE=64,
    INFO=128,
    DEBUG=256
}
-----------------------------------------------------------------------------------
local log_level_str={
    [tostring(log_level.STDERR)]="STDERR",
    [tostring(log_level.EMERG)]="EMERG",
    [tostring(log_level.ALERT)]="ALERT",
    [tostring(log_level.CRIT)]="CRIT",
    [tostring(log_level.ERR)]="ERR",
    [tostring(log_level.WARN)]="WARN",
    [tostring(log_level.NOTICE)]="NOTICE",
    [tostring(log_level.INFO)]="INFO",
    [tostring(log_level.DEBUG)]="DEBUG",
}
_M.log_level = log_level
-----------------------------------------------------------------------------------
-- 配置
local log_file_path="/tmp/kgHookLog"		--文件夹路径
local log_output_level=log_level.NOTICE
local log_file_keep_day = 7
local MyLog = function(lvl, ...) if lvl>log_output_level then return end print(...) end

-----------------------------------------------------------------------------------
--清理旧日志
local function clean_log_file()
    --make list which is in last seven days
    local time_latest = os.date("%Y%m%d", os.time()-60*60*24*log_file_keep_day)
	MyLog(log_level.NOTICE, "log file name: " ..time_latest)
    
    local cmd = "ls " ..log_file_path
    for i in io.popen(cmd):lines() do
        if i and tostring(i) < time_latest then
            local file_to_be_remove = log_file_path .."/" ..i
            MyLog(log_level.DEBUG, "remove log " ..file_to_be_remove)
            os.remove(log_file_path .."/" ..i)
        end
    end
end
-----------------------------------------------------------------------------------
local log_file_name = ""
_M.log_fd=nil
local function open_log_file()
    --prefare
    local cmd = "mkdir -p "..log_file_path
    local ret = os.execute(cmd)
    if 0 ~= ret then
        MyLog(log_level.ERR, "make directory failed. " .."[" ..cmd .."]" ..tostring(ret))
        return false
    end

    --新日志文件? link it
    local filename = log_file_path .."/" ..os.date("%Y%m%d")
    if log_file_name == filename then
		return
	end

    --打开日志文件 并设置到output
    log_file_name = filename
    _M.log_fd = io.open(log_file_name, "a+")
    io.output(_M.log_fd)

	--创建连接
    local cmd = "ln -sf " ..filename .." "  ..log_file_path .."/log"
	local ret = os.execute(cmd)
	if 0 ~= ret then
		MyLog(log_level.ERR, "make symbol link failed. " .."[" ..cmd .."]" ..tostring(ret))
		return false
	end

	--清除旧日志
	--clean_log_file()

end
-----------------------------------------------------------------------------------
local function Log(lvl, ... )
    --不在输出等级?
    if (lvl > log_output_level) then
        return
    end
    
    open_log_file()

	local msg = os.date("%Y-%m-%d %H:%M:%S") .." [".. log_level_str[tostring(lvl)] .."]"
	for i,v in ipairs( {...} ) do
		msg = msg .. " " .. tostring(v)
	end
    io.write(msg, "\r\n")
    io.flush()
end
-----------------------------------------------------------------------------------
--日志接口
_M.Log		= Log
_M.Info 	= function (...) _M.Log(log_level.INFO, ...) 	end
_M.Debug 	= function (...) _M.Log(log_level.DEBUG, ...) 	end
_M.Err 		= function (...) _M.Log(log_level.ERR, ...) 	end 
_M.Notice 	= function (...) _M.Log(log_level.NOTICE, ...) 	end 
_M.Warn 	= function (...) _M.Log(log_level.WARN, ...) 	end 
-----------------------------------------------------------------------------------
local function init()
    open_log_file()
    return true
end
-----------------------------------------------------------------------------------
init()
return _M
-----------------------------------------------------------------------------------
