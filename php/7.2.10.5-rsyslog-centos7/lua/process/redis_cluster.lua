----------------------------------------------------------------
local utility   = require("utility")
local log       = require("log")
local cjson     = require("cjson")
local common    = require("process.common")

----------------------------------------------------------------
local method_list = {
"get",
"set",
"mget",
"mset",
"del"
}

----------------------------------------------------------------
local _M = {}

----------------------------------------------------------------
local function GetLastError(vCallChain, vIndex)
	local gle = vCallChain[vIndex+1]
	if "getlasterror"~=gle.fname then
		log.Err("no getLastError");		
		return nil
	end

	return gle["return"]
end

----------------------------------------------------------------
local function process(vMessages, vIndex, vRetData)
    local obj = vMessages[vIndex]

    --need not reporter?
    if not utility.IsContain(method_list, obj.fname) then
        return nil
    end
	
    --get data for time
    local tStartTimeStr, tEndTimeStr, tTimeTaken = common.get_times(vMessages[vIndex])

	local Etable = {}
	Etable["getlasterror"] = GetLastError(vMessages, vIndex)

    local status = "0"
    --根据is_exception判断是否成功
    if obj["is_exception"] then 
        status = "1"
    end
    --根据getlasterror判断是否成功
    if Etable["getlasterror"] ~= nil then
        status = "1"
    end

    --获取key
    local key_limit = 5
    local key = obj.args.arg0 or ""
    if "table"==type(key) then
        local key_table = {}
        for k,v in pairs(key) do
            --key数量超出限制
            if key_limit == 0 then
                key_table[#key_table+1] = "..."
                break
            end
            key_limit=key_limit-1

            if "string"==type(k) then
                key_table[#key_table+1] = k
            else
                key_table[#key_table+1] = tostring(v)
            end
        end
        key = table.concat(key_table, ", ")
    end


    local Etable_json = cjson.encode(Etable)    
    vRetData[#vRetData+1] = common.data_package("Cache.RedisCluster", tStartTimeStr, tEndTimeStr, tTimeTaken, obj.fname, status, key, Etable_json)
end

----------------------------------------------------------------
_M.process = process
return _M

----------------------------------------------------------------
