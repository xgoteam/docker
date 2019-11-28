local _M = {}

_M.repoter_url = ""
_M.sum_table = { }
_M.data_type = {
   mysql = 1,
   redis = 2,
   memcache =3,
   curl =4,
}
_M.probability = 30
_M.max_time_per_request = 10
_M.default_server_id = 0
return _M
