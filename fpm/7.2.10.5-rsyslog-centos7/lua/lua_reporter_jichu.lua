print("start lua reporter\n");
package.cpath=package.cpath..";".."/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/?.so;/lua/?.so";
package.path=package.path..";".."/usr/local/lib/lua/5.1/?.lua;/usr/local/share/lua/5.1/?.lua;/lua/?.lua";
local log_m = require "log"
local log = log_m.log
--mysql:host=10.16.6.89;port=3306;dbname=d_fanxing_noncore2

if not get_service_id then
    get_service_id = function()
        return "1234"
    end
end

if not get_inner_ip then
    get_inner_ip = function()
        return "127.0.0.1"
    end
end

if not get_report_time then 
    get_report_time = function()
        local socket = require "socket"
        return socket.gettime() 
    end
end

function kg_hook_table_hex_to_bin(t, level) 
	local n_t = {}
	if level == 1 then
    	for k,v in pairs(t) do 
        	if type(v) == "table" then 
            	n_t[k] = kg_hook_table_hex_to_bin(v, level +1)
			else
				if type(v) == "string" and k ~= "fname" and k ~= "cname" then
            		n_t[k] = hex_to_bin(v)
				else
					n_t[k] = v
				end
        	end
		end
	else 
  		for k,v in pairs(t) do 
            if k ~= "handle" and k ~= "resource_id" then  
                k = tostring(hex_to_bin(k))
            end
        	if type(v) == "table" then 
            	n_t[k] = kg_hook_table_hex_to_bin(v, level +1)
			else
				if type(v) == "string" then
            		n_t[k] = hex_to_bin(v)
				else
					n_t[k] = v
				end
        	end
		end
    end
	return n_t
end


local package_map = {
    curl="process.curl",
    mysql = "process.mysql",
    pdo_mysql  = "process.pdo_mysql",
    memcache = "process.memcache",
    memcached = "process.memcached",
    redis = "process.redis",
}

local global = require "config.global"
local socket = require "socket"

function check_probability()
    math.randomseed(socket.gettime())
    local p = math.random(1, 100)
    if p <= global.probability then
        return true
    end 
    return false
end 
local cjson = require "cjson"
function report_to_server(cur_time)
    --[[
serverid
data_type
report_time
report_ip
    ]]
    local sum_table = global.sum_table 
	log(LOG_DEBUG, "reporter to server")
    for server_id, t in pairs(sum_table) do 
		log(LOG_DEBUG, "server_id", server_id, t)
        for _type, resource_map in pairs(t) do

			log(LOG_DEBUG, "type", _type, resource_map)
            for resource_name, detail in pairs(resource_map) do 
				log(LOG_DEBUG, "resourcename", resource_name, detail)
                local report_json = {}
                report_json.serverid = server_id
                report_json.data_type = global.data_type[_type]
                report_json.ip = get_inner_ip()
                report_json.report_time = curl_time
                report_json.detail = detail
				log(LOG_DEBUG, "before_encode", report_json)
                local data = cjson.encode(report_json)
                local url = global.repoter_url
				log(LOG_DEBUG, url, data)
                local ret, code = send_data_to_reporter(url,data)
                log(LOG_DEBUG, ret, code)
            end
        end
    end 
	return true
end

-- php version 5.3.17 5.2.14 
function  send_data_to_reporter(url, data)
    local http = require "socket.http"
    local r, c = http.request(url, data)
    return r,c
end
function process_request(local_ctx) 
    
	for i=1,#local_ctx do 
        local name = nil
		if local_ctx[i].fname == "curl_exec" then
            name = "curl"
		elseif local_ctx[i].cname == "Memcached" then
			name = "memcached"
		elseif local_ctx[i].cname == "Redis" then
            name = "redis"
		elseif local_ctx[i].cname == "PDO" or local_ctx[i].cname == "PDOStatement" then
			name = "pdo_mysql"
		elseif string.sub(tostring(local_ctx[i].fname), 1,string.len("memcache")) == "memcache" or local_ctx[i].cname == "Memcache" then 
			--ignore
            name = "memcache"
        elseif string.sub(tostring(local_ctx[i].fname), 1,string.len("mysql")) == "mysql" then 
			--ignore
            name = "mysql"
        else 
            
		end

        if name then 
            package = require(package_map[name])
            package.process(local_ctx, i)
        end
	end
    
end


local request_start_time = nil

function process_msg(msg) 
    log(LOG_DEBUG, msg)
	local t = cjson.decode(msg)	

	if type(t) =="table" then
        
		if t.start then 
			ctx = {} 
        end
        if not t.start and not t["end"] then 
            t = kg_hook_table_hex_to_bin(t,1)
         end
         log(LOG_DEBUG, "cjson.encode", cjson.encode(t))
		ctx[#ctx+1] = t
	end

	if t.start then
        request_start_time = socket.gettime()
	end

	if t["end"] then
        if t.request == ctx[1].request then
            log(LOG_DEBUG, "start_process_request\n")
            process_request(ctx)
            log(LOG_DEBUG, "end_process_request\n")
        else
            ctx = {}
        end
	end
	return true
end

local continue_count = 0
log(LOG_INFO, "start_loop")
while true do
	local str = fetch_msg()
	if str then
		local ret, err = pcall(process_msg, str)
		if not ret then
			log(LOG_ERR, "log by lua_reporter.lua", err)
		end
	else
		if(get_exit() == 1) then
    		local cur_time = socket.gettime()
			local ret, err = pcall(report_to_server, cur_time)
			if not ret then 
				log(LOG_ERR, "log_err", err)
			end
			log(LOG_INFO, "end_loop")
			return 0
		else 
			usleep(10)
		end
	end
    if get_exit() ~= 1 and request_start_time and  socket.gettime() - request_start_time > global.max_time_per_request then 
        --log(LOG_ERR, "request time is exceed "..global.max_time_per_request)
    end
    local cur_time = socket.gettime()
    if cur_time % 60 == 0 then 
		local ret, err = pcall(report_to_server, cur_time)
		if not ret then 
			log(LOG_ERR, "log_err", err)
		end
    end
end
log(LOG_INFO, "end_loop")
