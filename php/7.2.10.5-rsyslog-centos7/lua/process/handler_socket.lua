----------------------------------------------------------------
local utility   = require("utility")
local log       = require("log")
local cjson     = require("cjson")
local common    = require("process.common")

----------------------------------------------------------------
local method_list = {
"__construct",
"openIndex",
"executeSingle",
"executeMulti",
"executeUpdate",
"executeDelete",
"executeInsert",
}

----------------------------------------------------------------
local _M = {}

----------------------------------------------------------------
local function process(vMessages, vIndex, vRetData)
    local obj = vMessages[vIndex]

    --need not reporter?
    if not utility.IsContain(method_list, obj.fname) then
        return nil
    end
	
    --get data for time
    local tStartTimeStr, tEndTimeStr, tTimeTaken = common.get_times(vMessages[vIndex])

    --根据getlasterror判断是否正确
    local status = "0"
    if obj["is_exception"] then
        status = "1"
    end

    if obj.fname == "__construct" then
        --当前只有__construct接
        --获取地址
        local ip    = (obj.args.arg0 and tostring(obj.args.arg0)) or ""
        local port  = (obj.args.arg1 and tostring(obj.args.arg1)) or 0
        local addr  = "ip:"..ip .."," .."port:"..port 
        
        vRetData[#vRetData+1] = common.data_package("SQL.HS", tStartTimeStr, tEndTimeStr, tTimeTaken, obj.fname, status, addr)
    elseif obj.fname == "openIndex" then
        local dbbase  = (obj.args.arg1 and tostring(obj.args.arg1)) or ""
        local table  = (obj.args.arg2 and tostring(obj.args.arg2))  or ""
        local fname = obj.fname.."."..dbbase.."."..table
        vRetData[#vRetData+1] = common.data_package("SQL.HS", tStartTimeStr, tEndTimeStr, tTimeTaken, fname, status, dbbase.."."..table)
    else
        vRetData[#vRetData+1] = common.data_package("SQL.HS", tStartTimeStr, tEndTimeStr, tTimeTaken, obj.fname, status, "")
    end
	
end

----------------------------------------------------------------
_M.process = process
return _M

---------------------------------------------------------------