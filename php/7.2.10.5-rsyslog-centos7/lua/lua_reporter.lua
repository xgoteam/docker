print("start lua reporter\n");
package.cpath=package.cpath..";".."/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/?.so;/lua/5.1/?.so";
package.cpath=package.cpath..";/home/k/tmp/lua-package/?.so;/home/k/tmp/lua-package/lib/lua/5.1/?.so;/home/k/tmp/lua-package/lib/lua/5.1/?/?.so";
package.path=package.path..";".."/usr/local/lib/lua/5.1/?.lua;/usr/local/share/lua/5.1/?.lua";
package.path=package.path..";/home/k/tmp/lua-package/share/lua/5.1/?.lua;/home/k/tmp/lua-package/share/lua/5.1/?/?.lua"
-----------------------------------------------------------------------
local DEBUG_MOD		= false  				--调试模式开关, 开启将不上报CAT 只记日志
local DM_print_msg	= DEBUG_MOD and true	--调试模式下, 开启打印所有收到的消息.

local php_cat_ip_list = {
	{ip="cat-proxy.cat.svc.cluster.local", port=2280}
}
-----------------------------------------------------------------------
local log = require("log")
local utility = require("utility")
local cjson = require("cjson")
local business_func = require("business_func")

-----------------------------------------------------------------------
local ip_list = nil

if ip_list ~= "default" and ip_list ~= nil then 
    local t = {}
    ip_list = ip_list..","
    local start = 1
    for i=1,#ip_list do 
        if string.sub(ip_list, i, i) == "," then 
            local ip_port = string.sub(ip_list, start, i-1)
            start = i+1
            local ip = "127.0.0.1"
            local port = 8820
            for j=1,#ip_port do 
                if string.sub(ip_port, j, j) == ":" then 
                    ip = string.sub(ip_port, 1, j-1)
                    port = string.sub(ip_port, j+1, #ip_port)
                    port = tonumber(port)
                    t[#t+1] = {ip=ip, port = port}
                end
            end
        end
    end
    php_cat_ip_list = t
end
----------------------------------------------------------------
if not fetch_msg then 
	fetch_msg = function()
		local t = {}
		t["a"]=1
		return cjson.encode(t)
	end
end

log.Debug( cjson.encode(php_cat_ip_list))
local send_data = {}
----------------------------------------------------------------
--request_context
local function resource_get(request_context, resource_id)
	--is not existing?
	if not request_context.handles[tostring(resource_id)] then
		request_context.handles[tostring(resource_id)] = {}
	end
		
	return request_context.handles[tostring(resource_id)]
end

local function resource_IsExisting(request_context, resource_id)
	return nil~=request_context.handles[tostring(resource_id)]
end
----------------------------------------------------------------
-- curl 
function curl_pack_send_data(start_format_time, url, next_message_id, param, end_format_time, status, use_us, attached_data)
	local attached_data_json = cjson.encode(attached_data)

	local data = ""
--[[
 t2016-03-05 17:25:15.196    Call    com.kugou.fanxing.template.thrift.UserIdMappingService:getKugouIdByUserId    
 E2016-03-05 17:25:15.196    RemoteCall        0    fx_template-ac1109eb-404769-60    
 T2016-03-05 17:25:15.236    Call    com.kugou.fanxing.template.thrift.UserIdMappingService:getKugouIdByUserId    0    40987us
 local str = curl_pack_send_data(start_format_time, url, tostring(next_message_id), param, end_format_time, status, use_us)
]]
	data = data.."t"..start_format_time.."\tCall\t"..url.."\t\n"
	data = data.."E"..end_format_time.."\tRemoteCall\t\t"..status.."\t"..next_message_id.."\t\n"
	-- 暂时屏蔽param,因其影响cat上TYPE的显示
	-- data = data.."T"..end_format_time.."\tCall\t"..url.."\t"..status.."\t"..use_us.."us\t"..param.."\t\n"
	data = data.."T"..end_format_time.."\tCall\t"..url.."\t"..status.."\t"..use_us.."us\t"..attached_data_json.."\t\n"

	log.Debug(curl_pack_send_data)
	return data
end
----------------------------------------------------------------
function curl_fetch_url(ctx, p_i)
	local url = ""
	for i=p_i-1,1,-1 do 
		if ctx[i].fname=="curl_setopt" and ctx[i]["arg0"].resource_id == ctx[p_i]["arg0"].resource_id then	
		--[[
		"arg0":{"resource_id": 4},"arg1":10002,"arg2":"http:\/\/127.0.0.1\/","return":true, "call_end_time_sec":1458364655,"call_end_time_usec":180692}
fetch_msg in c {"call_start_time_sec":1458364655,"call_start_time_usec":180688, "request_id":1,"fname":"curl_setopt","arg0":{"resource_id": 4},"arg1":10002,"arg2":"http:\/\/127.0.0.1\/","return":true, "call_end_time_sec":1458364655,"call_end_time_usec":180692}
		]]			
			if ctx[i].arg1 == 10002 then
				local url = ctx[i].arg2
				-- for j=1,#url do 
				-- 	if string.sub(url, j,j) == "?" then
				-- 		url = string.sub(url, 1,j-1)	
				-- 		return url
				-- 	end	
				-- end
				return url
			end
		end
	end
	return url
end
----------------------------------------------------------------
function curl_fetch_param(ctx, p_i)
	local param = ""
	log.Debug("cur_fetch_param")
	for i=p_i-1,1,-1 do 
		if ctx[i].fname=="curl_setopt" and ctx[i]["arg0"].resource_id == ctx[p_i]["arg0"].resource_id then	
			if ctx[i].arg1 == 10002 then
				local url = ctx[i].arg2
				for j=1,#url do 
					if string.sub(url, j,j) == "?" then
						local param = string.sub(url, j+1, #url)	
						return param
					end	
				end
			end
			log.Debug( "cur_fetch_param out", ctx[i].arg1)
			if ctx[i].arg1 == 10015 then
			log.Debug( "cur_fetch_param in", ctx[i].arg1)
				local post_data = ctx[i].arg2
					param = ""
					if type(post_data) == "string" then
						param = post_data
					elseif type(post_data) == "table" then
						for k,v in pairs(post_data) do
							if type(v) == "table" then v = cjson.encode(v) end
							if param ~= "" then
								param = param.."&"..k.."="..tostring(v)
							else
								param = k.."="..tostring(v)
							end
						end
					else
					end
			end
		end
	end
	return param
end
----------------------------------------------------------------
function curl_fetch_next_message(ctx, p_i)
		local next_mid = ""
	for i=p_i-1,1,-1 do 
		if ctx[i].fname=="curl_setopt" and ctx[i]["arg0"].resource_id == ctx[p_i]["arg0"].resource_id then	
			if ctx[i].arg1 == 10023 then
--[[
kg_hook_lua_reporter_fetch_message write_pos:5242880 read_pos:3145728 {"call_start_time_sec":1458365676,"call_start_time_usec":109951, "request_id":1,"fname":"curl_setopt","arg0":{"resource_id": 4},"arg1":10023,"arg2":{"trace_index_0":"catcontextheader: test.kugou.com;10.1.2.7;;;432;456"},"return":true, "call_end_time_sec":1458365676,"call_end_time_usec":109954}
]]
				local obj = ctx[i].arg2
				for k, v in pairs(obj) do
					log.Debug( "next_message", k,v)
					if string.match(v,"catcontextheader") then
						for j=#v,1,-1 do 
							if string.sub(v,j,j) == ";" then
								local nid = string.sub(v,j+1,#v)
								nid = string.gsub(nid, " ", "")
								return nid
							end
						end
					end
				end
			end
		end
	end
	return next_mid

end
----------------------------------------------------------------
--local CURLINFO_HTTP_CODE = 2097154
--local function process_curl_getinfo(ctx, p_i, request_context)
--	local msg = ctx[p_i]
--	local t_return = msg["return"]
--	local resource_id = msg.arg0 and msg.arg0.resource_id
--
--	--no retrun?
--	if not t_return then
--		return
--	end
--
--	if msg.arg1 ~= CURLINFO_HTTP_CODE then
--		return
--	end
--
--	local resource = resource_get(request_context, resource_id)
--	resource["curl_status_code"] = tonumber(t_return)
--	
--	log.Debug("resource_"..resource_id, "status_code="..t_return)
--end
--
--local function curl_get_status_code(request_context, resource_id)
--	if true ~= resource_IsExisting(request_context, resource_id) then
--		return nil
--	end
--
--	local resource = resource_get(request_context, resource_id)
--	return resource["curl_status_code"]
--end
----------------------------------------------------------------
--从调用中获取curl_exec状态码
local CURLINFO_HTTP_CODE = 2097154
local function curl_get_status_code_from_callchain(callchain, index_start)
--[[
"arg0":{"resource_id": 4},"arg1":10002,"arg2":"http:\/\/127.0.0.1\/","return":true, "call_end_time_sec":1458364655,"call_end_time_usec":180692}
fetch_msg in c {"call_start_time_sec":1458364655,"call_start_time_usec":180688, "request_id":1,"fname":"curl_setopt","arg0":{"resource_id": 4},"arg1":10002,"arg2":"http:\/\/127.0.0.1\/","return":true, "call_end_time_sec":1458364655,"call_end_time_usec":180692}
]]

	local this = callchain[index_start]
	local resource_id = tonumber(this.arg0.resource_id)

	for i=index_start+1, #callchain do
		local iter = callchain[i]
		while true do
			if "curl_getinfo"~=iter.fname then break end
			if resource_id~=iter.arg0.resource_id then break end

			--探针扩展模块调用的curl_getinfo
			if 0==iter.arg1 and iter["return"] and iter["return"]["connect_time"] then
				local ret = iter["return"]
				--连接时间大于100ms, 看作失败
				if ret["connect_time"] >= 100 then
					return 10000
				end

				return ret["http_code"]
			end

			if CURLINFO_HTTP_CODE~=iter.arg1 then break end
			return iter["return"]
		end
	end
end
----------------------------------------------------------------
--从后续调用中获取curl_exec的错误信息
local function curl_get_error_string(callchain, index_start)
--[[
{"call_end_time_sec":1472643443,"call_start_time_usec":183156,"call_end_time_usec":183156,"return":"couldn't connect to host","args":{"arg0":{"resource_id":4}},"fname":"curl_error","call_start_time_sec":1472643443,"request_id":1}
]]
	local this = callchain[index_start]
	local resource_id = tonumber(this.arg0.resource_id)

	for i=index_start+1, #callchain do
		local iter = callchain[i]
		while true do
			if "curl_error"~=iter.fname then break end
			if resource_id~=iter.arg0.resource_id then break end

			return iter["return"]
		end
	end
end
----------------------------------------------------------------
function process_curl(ctx, p_i, request_context) 
	local start_sec = ctx[p_i].call_start_time_sec
	local start_usec = ctx[p_i].call_start_time_usec
	local end_sec = ctx[p_i].call_end_time_sec
	local end_usec = ctx[p_i].call_end_time_usec
	local status = "0"
	log.Debug( "process_curl", p_i)
	--从返回值判断是否成功
	-- if ctx[p_i]["return"] == false or ctx[p_i]["return"] == cjson.null then
	-- 	status = "1"
	-- end

	--从状态码判断是否成功
	local status_code = curl_get_status_code_from_callchain(ctx, p_i) 
	if status_code and 400<=status_code then
		status = "1"
	end

	local use_us = us_diff(start_sec, start_usec, end_sec, end_usec)
	local start_format_time = format_str_time(start_sec, start_usec)
	local end_format_time = format_str_time(end_sec, end_usec)
	local param = curl_fetch_param(ctx, p_i)
	local next_message_id =curl_fetch_next_message(ctx, p_i)
	
	--url处理
	local url = curl_fetch_url(ctx, p_i)
	url = string.gsub(url,"/%d+/","/{d}/")

	--todo,replace \t \n, 防止与上报信息格式的token冲突
	--param = string.gsub(param, "\t", "\\t")
	--param = string.gsub(param, "\n", "\\n")
	
	local errmsg = curl_get_error_string(ctx, p_i)
	local attached_data = {}
	attached_data["err_msg"] = errmsg

    --时间超过2秒记为失败 或 curl_error有错误信息
    if use_us > 2000000 then
        status = "1"
    end
    if attached_data["err_msg"] ~= nil and #attached_data["err_msg"] > 0 then
        status = "1"
    end
    
	local str = curl_pack_send_data(start_format_time, url, tostring(next_message_id), param, end_format_time, status, use_us, attached_data)
	log.Debug( "process_curl", str)
	send_data[#send_data+1] = str
end
----------------------------------------------------------------
function pdo_pack_send_data(start_format_time,cname, fname, dbn,sql,status, end_format_time, use_us, is_prepare)
--[[
 t2016-03-05 17:15:07.022    SQL    com.kugou.fanxing.template.dao.mysql.TestDao.get    
 E2016-03-05 17:15:07.022    SQL.Method    SELECT    0        
 E2016-03-05 17:15:07.022    SQL.Database    jdbc:mysql://10.16.6.89/cat    0        
 T2016-03-05 17:15:07.478    SQL    com.kugou.fanxing.template.dao.mysql.TestDao.get    0    456132us    sql=select id from project limit 1
]]
    local data = ""
--[[
	data = data.."t"..tostring(start_format_time).."\tSQL\t"..tostring(cname).."."..tostring(fname).."\t\n"
	data = data.."E"..tostring(start_format_time).."\tSQL.Database\t"..tostring(dbn).."\t"..tostring(status).."\t\t\n"
	data = data.."T"..tostring(end_format_time).."\tSQL\t"..tostring(cname).."."..tostring(fname).."\t"..tostring(status).."\t"..use_us.."us\t".."sql="..tostring(sql).."\t\n"
]]
	local name = tostring(cname).."."..tostring(fname)
	if is_prepare then 
		name = sql 
	end

	data = data.."t"..tostring(start_format_time).."\tSQL\t"..name.."\t\n"
	data = data.."E"..tostring(start_format_time).."\tSQL.Database\t"..tostring(dbn).."\t"..tostring(status).."\t\t\n"
	data = data.."T"..tostring(end_format_time).."\tSQL\t"..name.."\t"..tostring(status).."\t"..use_us.."us\t".."sql="..tostring(sql).."\t\n"

	log.Debug( "pdo_pack_send_data", data)
	return data
end
----------------------------------------------------------------
function process_pdo(ctx, p_i, request_context)

    local obj = ctx[p_i]

	if obj.fname == "query" or obj.fname == "exec" or obj.fname == "execute" or obj.fname=="__construct" then
	else
		return 
	end	

	local start_sec = ctx[p_i].call_start_time_sec
	local start_usec = ctx[p_i].call_start_time_usec
	local end_sec = ctx[p_i].call_end_time_sec
	local end_usec = ctx[p_i].call_end_time_usec
 	local use_us = us_diff(start_sec, start_usec, end_sec, end_usec)

	local start_format_time = format_str_time(start_sec, start_usec)
	local end_format_time = format_str_time(end_sec, end_usec)
	local status = "0"
	if ctx[p_i]["return"] == false or ctx[p_i]["return"] == cjson.null then
		status = "1"
	end
	log.Debug( "process PDO", obj.cname, obj.fname)


	--处理PDO.__construct, 管理资源
	while true do
		if obj.cname~="PDO" or "__construct"~=obj.fname then break end

		--管理construct的资源
		while true do
			if not obj.this or not obj.this.handle then break end
			if not obj.arg0 then break end

			if not obj.this or not obj.this.handle then break end
			local handle={}
			handle.dbname = obj.arg0

			request_context.handles[tostring(obj.this.handle)] = handle
			log.Debug("handle_"..tostring(obj.this.handle), "dbname="..obj.arg0)
			break
		end
	
		--上报
		local status = obj.this and "0" or "1"
		local dbn = obj.arg0
        	local sql = "connect"
		local str = pdo_pack_send_data(start_format_time, obj.cname, obj.fname, dbn,sql,status, end_format_time, use_us, false)
		send_data[#send_data+1] = str
		return
	end
	
	--上报 PDO.query 和 PDO.exec
    if obj.cname == "PDO" and (obj.fname == "query" or obj.fname == "exec") then
		--获取db名
		local dbn = ""
		local handle = request_context.handles[tostring(obj.this.handle)]
		if handle and handle.dbname then
			dbn = handle.dbname
		end
		--通过前面的contruct获取db名
		--[[
        for i=p_i-1,1,-1 do
            if ctx[i].this and ctx[i].this.handle == obj.this.handle and ctx[i].fname == "__construct" then 
                dbn = ctx[i].arg0
            end
        end
		]]

        local sql = obj.arg0
        local str = pdo_pack_send_data(start_format_time, obj.cname, obj.fname, dbn,sql,status, end_format_time, use_us, false)
	    send_data[#send_data+1] = str

    elseif obj.cname == "PDOStatement" and obj.fname == "execute" then 
        local dbn = ""
        local pdo_handle = nil
        local pdo_i = 0
		local sql = "unkown"
        for i=p_i-1,1,-1 do
            if ctx[i].fname == "prepare"  and ctx[i]["return"].handle == obj.this.handle then 
                pdo_handle = ctx[i].this.handle
                pdo_i = i
				sql = ctx[i].arg0
				break
            end
        end

		--获取db名
		local handle = request_context.handles[tostring(obj.this.handle)]
		if handle and handle.dbname then
			dbn = handle.dbname
		end
		--[[
        for i=pdo_i-1,1,-1 do
            if ctx[i].fname == "__construct"  and ctx[i].this.handle == pdo_handle then 
                dbn = ctx[i].arg0
            end
        end
		]]
        sql = string.gsub(sql, "['\"].-['\"]", "'?'")
        sql = string.gsub(sql, "%d+", "?")
        sql = string.gsub(string.lower(sql), "in%s*%(.-%)", "in('?')")
 
        local str = pdo_pack_send_data(start_format_time,obj.cname, obj.fname, dbn,sql,status, end_format_time, use_us, true)
	    send_data[#send_data+1] = str
    end
end
----------------------------------------------------------------
function memcache_pack_send_data(start_format_time, fname, obj, end_format_time, status, rc, use_us, attached_data)
	local keys = ""
	if fname == "cas" then
		keys = obj.arg1
	else
		keys = obj.arg0
	end

	local key = ""
	if type(keys) == "table" then
		local first = true
		for k,v in pairs(keys) do
			if fname == "getMulti" or fname == "deleteMulti" then
				if first then 
					key = tostring(v)
					first = false
				else
					key = key .. "&"..tostring(v)
				end
			else
				if first then 
					key = tostring(v)
					first = false
				else
					key = key .. "&"..tostring(v)
				end
			end
		end
	elseif type(keys) == "string" then 
        key = keys
    else
		key = tostring(keys)
	end
	if fname == "quit" then key = "" end

	--如果存在server信息 则修改成 fname@ip:port 的格式
	local server_info = attached_data["server"]
	if server_info then
        if server_info["host"] ~= nil then
            fname = fname .."@"..tostring(server_info["host"]) ..":"..tostring(server_info["port"])
        else
            fname = fname .."@"..tostring(server_info["host\0"]) ..":"..tostring(server_info["port\0"])
        end
	end

	local attached_data_json = cjson.encode(attached_data)

    local data = ""
	data = data.."t"..tostring(start_format_time).."\tCache.mc\t"..tostring(fname).."\t\n"
	data = data.."E"..tostring(start_format_time).."\tCache.mc\t"..tostring(fname).."\t"..status.."\t"..attached_data_json.."\t\n"
	if attached_data["result_code"] ~= nil and attached_data["result_code"] == 16 then
		data = data.."E"..tostring(start_format_time).."\tCache.mc\t"..tostring(fname)..":miss".."\t".."\t"..attached_data_json.."\t\n"
	end
	--data = data.."E"..tostring(start_format_time).."\tCache.mc\t"..tostring(fname).."\t"..tostring(status).."\t\t\n"
	--data = data.."E"..tostring(start_format_time).."\tCache.mc\t"..tostring(fname).."\t"..tostring(status).."\t\t\n"
	--data = data.."T"..tostring(end_format_time).."\tCache.mc\t"..tostring(fname).."\t"..tostring(status).."\t"..use_us.."us\t"..key.."\t\n"
	data = data.."T"..tostring(end_format_time).."\tCache.mc\t"..tostring(fname).."\t"..status.."\t"..use_us.."us\t"..key.."\t\n"
	return data	
end
----------------------------------------------------------------
memcache_method_list = {
"add",
"append",
"cas",
"decrement",
"delete",
"deleteMulti",
"get",
"getMulti ",
"increment ",
"prepend ",
"quit",
"replace",
"set",
"setMulti",

--[[
"getResultCode",
"getResultMessage",
"getServerByKey"
]]
}

memcache_method_with_result = {
"get",
"set",
"add",
"delete",
"decrement",
"increment",
"append"
}

function process_memcache(ctx, p_i)
    local obj = ctx[p_i]

    local start_sec = ctx[p_i].call_start_time_sec
	local start_usec = ctx[p_i].call_start_time_usec
	local end_sec = ctx[p_i].call_end_time_sec
	local end_usec = ctx[p_i].call_end_time_usec
    local use_us = us_diff(start_sec, start_usec, end_sec, end_usec)
	local start_format_time = format_str_time(start_sec, start_usec)
	local end_format_time = format_str_time(end_sec, end_usec)

	local attached_data = {}
	--with getResultCode, getResultMessage, getServerByKey
	if utility.IsContain(memcache_method_with_result, obj.fname) then
		local m_rc = ctx[p_i+1]
		local m_rm = ctx[p_i+2]
		local m_sk = ctx[p_i-1]

		if not m_rc or m_rc.fname~="getResultCode" then
			log.Err("[no getResultCode]", obj.fname);
		else
			attached_data["result_code"] = m_rc["return"]
		end

		if not m_rm or m_rm.fname~="getResultMessage" then 
			log.Err("[no getResultMessage]", obj.fname); 
		else
			attached_data["result_message"] = m_rm["return"]
		end


--[[
 {"call_end_time_sec":1472728335,"call_start_time_usec":168144,"call_end_time_usec":168146,"args":{"arg0":"clanActiveListForIndex"},"call_start_time_sec":1472728335,"request_id":1,"return":{"host\u0000":"10.16.6.90","port\u0000":33210,"weight\u0000":0},"arg0":"clanActiveListForIndex","fname":"getServerByKey","cname":"Memcached","this":{"handle":6}}
]]
		if not m_sk or m_sk.fname~="getServerByKey" then 
			log.Err("[no getServerByKey]", obj.fname); 
		else
			attached_data["server"] = m_sk["return"]

		end


	end

	local next_msg = ctx[p_i+1]
	local rc = "0"
	if next_msg and next_msg.fname == "getResultCode" and next_msg["return"] then 
		rc = next_msg["return"]
		if type(rc) ~= "number" then 
			rc = 0
		end
		
		rc = 0 -- todo, 应伍继林需求, 暂时性不打印此处日志
		log.Debug( "memcache resultcode", rc)
	end

    local status = "0"
    --通过返回值判断
    if attached_data["result_code"] ~= nil and utility.IsContain({0,14,15,16,32}, attached_data["result_code"]) == false then
        status = "1"
    end

	
	for _,v in pairs(memcache_method_list) do
		if string.lower(v) == string.lower(obj.fname) then
			local str = memcache_pack_send_data(start_format_time, obj.fname, obj, end_format_time, status,rc, use_us, attached_data)
			if str then
				send_data[#send_data+1] = str    
			end
			break
		end
	end
end
----------------------------------------------------------------
function redis_pack_send_data(start_format_time, fname, keys, end_format_time, status, use_us, attached_data)
	local key = ""

	log.Debug( "redis_pack_send_data",keys)
	if type(keys) == "table" then
		local count = 3
		local first = true
		for k,v in pairs(keys) do
			if keys["0"]  then
				if first then 
					key = tostring(v)
					first = false
				else
					key = key .. "&"..tostring(v)
				end
			else
				if first then 
					key = tostring(v)
					first = false
				else
					key = key .. "&"..tostring(v)
				end
			end
		end
	elseif type(keys) == "string" then 
		key = tostring(keys)
    else
		key = tostring(keys)
	end

	local attached_data_json = cjson.encode(attached_data)

    local data = ""
	data = data.."t"..tostring(start_format_time).."\tCache.redis\t"..tostring(fname).."\t\n"
	data = data.."E"..tostring(start_format_time).."\tCache.redis\t"..tostring(fname).."\t"..tostring(status).."\t"..attached_data_json.."\t\n"
	data = data.."T"..tostring(end_format_time).."\tCache.redis\t"..tostring(fname).."\t"..tostring(status).."\t"..use_us.."us\t"..key.."\t\n"
	log.Debug( data)
	return data	
end
----------------------------------------------------------------
local redis_menthod_with_getLastError = 
{
"get",
"rPush",
"rPop",
"publish",
"lPush"
}
----------------------------------------------------------------
local function redis_menthod_getLastError(callchain, index)
	local obj = callchain[index]
	if not utility.IsContain(redis_menthod_with_getLastError, obj.fname) then
		return nil
	end

	local gle = callchain[index+1]
	if "getLastError"~=gle.fname then
		log.Err("no getLastError");		
		return nil
	end

	return gle["return"]
end
----------------------------------------------------------------
redis_method_list = {
"connect",
"pconnect",

"get",
"set",
"del",
"ttl",
"expire",
"expireAt",
"publish",
"subscribe",

"hGetAll",
"hDel",
"hMset",
"hIncrBy",
"hSet",
"hExists",
"hLen",
"hKeys",
"hGet",
"sAdd",
"sMembers",
"sRandMember",
"sIsMember",
"rPush",
"lPop",
"lPush",
"rPush",
"rPop",
"lLen",
"zRevRange",
"zRemRangeByRank",
"zAdd",
"zRem",
"zSize",
"zRevRangeByScore",
}

function process_redis(ctx, p_i)
    local obj = ctx[p_i]
    local start_sec = ctx[p_i].call_start_time_sec
	local start_usec = ctx[p_i].call_start_time_usec
	local end_sec = ctx[p_i].call_end_time_sec
	local end_usec = ctx[p_i].call_end_time_usec
    local use_us = us_diff(start_sec, start_usec, end_sec, end_usec)
	local start_format_time = format_str_time(start_sec, start_usec)
	local end_format_time = format_str_time(end_sec, end_usec)
	
	local attached_data = {}
	attached_data["getLastError"] = redis_menthod_getLastError(ctx, p_i)

    local status = "0"
    if attached_data["getLastError"] ~= nil then
        status = "1"
    end
	
	log.Debug( "process redis", obj.fname)
	for _,v in pairs(redis_method_list) do
		if string.lower(v) == string.lower(obj.fname) then
			local str = redis_pack_send_data(start_format_time, obj.fname, obj.arg0, end_format_time, status, use_us, attached_data)
			send_data[#send_data+1] = str    
			break
		end
	end
end
----------------------------------------------------------------
local handler_RedisCluster = require("process.redis_cluster")
local handler_HandlerSocket= require("process.handler_socket")

function process_request(local_ctx)
local request_context={}
request_context.handles={}

	for i=1,#local_ctx do 
		local ret = nil
		local err = nil
		local proc_name = nil
		if local_ctx[i].fname=="curl_exec" then
			proc_name = "curl_exec"
			ret, err = pcall(process_curl,local_ctx, i, request_context)

--		elseif local_ctx[i].fname=="curl_getinfo" then
--			proc_name = "curl_getinfo"
--			ret, err = pcall(process_curl_getinfo, local_ctx, i, request_context)

		elseif local_ctx[i].cname == "Memcached" then
			proc_name = "memcache"
			ret,err = pcall(process_memcache,local_ctx, i)

		elseif local_ctx[i].cname == "Redis" then
			proc_name = "redis"
			ret, err = pcall(process_redis,local_ctx,i)

		elseif local_ctx[i].cname == "PDO" or local_ctx[i].cname == "PDOStatement" then
			proc_name = "pdo"
			ret, err = pcall(process_pdo,local_ctx,i, request_context)

		elseif local_ctx[i].cname == "RedisCluster" then
			proc_name = "redis_cluster"
			ret, err = pcall(handler_RedisCluster.process, local_ctx, i, send_data)

		elseif local_ctx[i].cname == "HandlerSocket" then
			proc_name = "HandlerSocket"
			ret, err = pcall(handler_HandlerSocket.process, local_ctx, i, send_data)

		else
			--ignore
		end

		if not ret and proc_name then
			log.Err(proc_name,"error", err)
		end
	end	
end
----------------------------------------------------------------
ctx = {}
function request_start(ctx)

    local obj = ctx[1]
	local type = "URL"
	if obj["has_cat_context"] then
		type = "Service"
	end

    local data = "PT1\t"..obj.domain.."\t"..obj.host_name.."\t"..obj.ip.."\t\t\t\t"..obj.mid.."\t"..obj.pid.."\t"..obj.rid.."\tnull\t\n";
    data = data .."t".. format_str_time(obj.time_sec, obj.time_usec).."\t"..type.."\t"..obj.url.."\t\n";
	log.Debug( "request_start", data)
    return data

end
----------------------------------------------------------------
function request_end(ctx)
    local obj_start = ctx[1]
    local obj_end = ctx[#ctx]
    local status = "0"
    status = business_func.request_end_status(obj_start.url,obj_end.code)
    local use_us = us_diff(obj_start.time_sec, obj_start.time_usec, obj_end.time_sec, obj_end.time_usec)
	local end_time_str = format_str_time(obj_end.time_sec, obj_end.time_usec)
    local data = ""
	data = data.."T"..end_time_str.."\tURL\t"..obj_start.url.."\t"..status.."\t"..use_us.."us\tcode:"..obj_end.code.."\t\n"
	log.Debug( "request_end", obj_start.time_sec, obj_start.time_usec, obj_end.time_sec, obj_end.time_usec, obj_start.url, obj_end.url, data)
    return data 
end
----------------------------------------------------------------
local socket = require("socket")
local cur_i = 1
--[[
local file = "/"
local sock = assert(socket.connect(host, 80))  -- 创建一个 TCP 连接，连接到 HTTP 连接的标准 80 端口上
sock:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
]]
local failed_retry_time = 10
function send_to_cat(send_data)
    local str = ""
    for i=1,#send_data do 
        str = str..send_data[i]
    end
    log.Debug("send_to_cat data before ", string.len(str), str)
    local str = get_bin_send_data(str)
    if not str then return false end
    local try_count = 3
    for i=1,try_count do 
        if (php_cat_ip_list[cur_i].failedtime and socket.gettime() - php_cat_ip_list[cur_i].failedtime > failed_retry_time) or php_cat_ip_list[cur_i].failedtime == nil  then
            -- log(LOG_DEBUG, "cur_i "..cur_i)
            if not php_cat_ip_list[cur_i].sock  then 
            local sock = socket.tcp()
            sock:settimeout(2)
                    local rc = sock:connect(php_cat_ip_list[cur_i].ip, php_cat_ip_list[cur_i].port)
            if rc then
                    php_cat_ip_list[cur_i].sock = sock
                    -- log(LOG_INFO, "connect to ",php_cat_ip_list[cur_i].ip, php_cat_ip_list[cur_i].port, sock)
            else
                    -- log(LOG_INFO, "connect failed ",php_cat_ip_list[cur_i].ip, php_cat_ip_list[cur_i].port, sock)
                sock:close()
                sock = nil
            end
            end
            if php_cat_ip_list[cur_i].sock then
                php_cat_ip_list[cur_i].failedtime = nil 
                local sock = php_cat_ip_list[cur_i].sock
                -- log(LOG_DEBUG, "cur_i sock "..cur_i)
                if sock then 
                    local ret = sock:send(str)
                    -- log(LOG_DEBUG, "send_to_cat", ret,"\n")
                    if not ret then 
                        sock:close()
                        php_cat_ip_list[cur_i].sock = nil
            else
                cur_i = cur_i + 1
                if cur_i > #php_cat_ip_list  then 
                    cur_i = 1
                end
                return true 
                    end
                end    
            else
                php_cat_ip_list[cur_i].failedtime = socket.gettime()
            end
        end
        cur_i = cur_i + 1
        if cur_i > #php_cat_ip_list  then 
            cur_i = 1
        end
        -- log(LOG_DEBUG, "after cur_i",cur_i)

    end
    return false
end

---------------解析url---------------------------------------------------
function url_decode (s)
    return s:gsub ('+', ' '):gsub ('%%(%x%x)', function (hex) return string.char (tonumber (hex, 16)) end)
end
function parseUrlString (url)
    local res = {}
    -- url = url:match '?(.*)$'
    for name, value in url:gmatch '([^?&=]+)=([^&=]*)' do
        value = url_decode (value)
        local key = name:match '%[([^&=]*)%]$'
        if key then
            name, key = url_decode (name:match '^[^[]+'), url_decode (key)
            if type (res [name]) ~= 'table' then
                res [name] = {}
            end
            if key == '' then
                key = #res [name] + 1
            else
                key = tonumber (key) or key
            end
            res [name] [key] = value
        else
            name = url_decode (name)
            res [name] = value
        end
    end
    return res
end


----------------------------------------------------------------
local cmsgpack = require "cmsgpack"
function process_msg(msg) 
	local resume_offset, t = cmsgpack.unpack_one(msg)	

	-- 调试模式下, 打印所有收到的消息
	if DM_print_msg then
		log.Notice("msg: \n", cjson.encode(t))
	end

	if "table"~=type(t) then
		log.Err( "is not a table")
		return true
	end

	if t.url and t.REQUEST_URI and "unknown"~=t.REQUEST_URI then
		t.url,t.REQUEST_URI = business_func.process_msg_uri(t.url,t.REQUEST_URI)
	end
	
	if type(t) =="table" then
        
		if t.start then 
			ctx = {} 
        end
        if not t.start and not t["end"] then 
            --t = kg_hook_table_hex_to_bin(t,1)
         end
		ctx[#ctx+1] = t
	end
	if type(t) ~= "table" then log.Debug( "error", t) return end
	if type(t.args) == "table" then 
		for k,v in pairs(t.args) do 
			t[k] = v
		end
	end
	--log.Debug( "cjson.encode", cjson.encode(t))

	if t.start then
		send_data = {}
        send_data[1] = request_start(ctx)
	end

	if t["end"] then
        if t.request == ctx[1].request then
            log.Debug( "start_process_request\n")
            process_request(ctx)
            log.Debug( "end_process_request\n")
            local str  = request_end(ctx)
            send_data[#send_data+1] = str
            
            if DEBUG_MOD then
                local msglog="report to CAT: \n=============================>"
                for i,v in pairs(send_data)do
                    msglog = msglog.."\n"..v;
                end
                msglog=msglog.."\n<================================"
				--todo, 解开
                log.Notice(msglog)
            else
				log.Info("send_to_cat data: \n", cjson.encode(send_data))
                if true~=send_to_cat(send_data) then
					log.Err("send_to_cat failed: \n", cjson.encode(send_data))
				end
            end

            send_data = {}
        else
            ctx = {}
            send_data = {}
        end
	end
	return true
end
----------------------------------------------------------------
local continue_count = 0
log.Notice( "start_loop")
local sleep_time_us = 1
local sleep_time_max= 10000

while true do
	repeat

	--process msg
	local str = fetch_msg()
	if str then
		local ret, err = pcall(process_msg, str)
		if not ret then
			log.Err( "log by lua_reporter.lua", err)
		end

		sleep_time_us = 1
		break
	end
		
	-- request exit
	if(get_exit() == 1) then
		usleep(1000000)
		log.Notice( "end_loop")
		return 0
	end

	--sleep
	usleep(sleep_time_us)
	sleep_time_us = sleep_time_us*2
	if sleep_time_us>sleep_time_max then
		sleep_time_us = sleep_time_max
	end

	until(true)
end
log.Notice( "end_loop")
----------------------------------------------------------------
