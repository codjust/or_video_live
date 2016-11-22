local upload = require "resty.upload"
local cjson  = require "cjson"

-- curl  -F "filename=@/home/test/file.tar.gz" http://127.0.0.1/api/upload_video.json?filename=
-- curl  -F "filename=@test.mp4" 'http://127.0.0.1/api/upload_video.json?filename=test.mp4'
local args = ngx.req.get_uri_args()
if not args then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local filename = ""
filename = args["filename"]

local response = {}
response.msg   = "upload success"

local res, err = ngx.re.match(filename, [[\.(?:mp4|flv)$]])
if not res then
    response.msg = "only mp4 and flv file can upload"
    ngx.say(cjson.encode(response))
    return
end

if err then
    ngx.log(ngx.ERR,"match err:", err)
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local chunk_size =  4096 -- should be set to 4096 or 8192

local save_file_path
if res[0] == ".mp4" then
    save_file_path = "/var/mp4s/" .. filename
elseif res[0] == ".flv" then
    save_file_path = "/var/flvs/" .. filename
else
    save_file_path = filename
end

local form, err = upload:new(chunk_size)
if not form then
    ngx.log(ngx.ERR, "failed to new upload: ", err)
    ngx.exit(500)
end

form:set_timeout(1000) -- 1 sec

local function close_file( write_file )
    if io.type(write_file) == "file" then  -- write_file处于打开状态，则关闭文件。
        write_file:close()
        write_file = nil
    end
end

local write_file -- 文件句柄
while true do
    local typ, recv, err = form:read()
    if not typ then
       --ngx.say("failed to read file: ", err)
        response.msg = "failed to read file"
        break
    end

    if typ == "header" and "file" ~= io.type(write_file) then
        write_file, err = io.open(save_file_path,'wb+')
        if err then
            ngx.log(ngx.ERR, "failed create hd:" ,err)
            response.msg = "failed create hd"
            break
        end
    elseif typ == "body" and "file" == io.type(write_file) then
        write_file:write(recv)
    elseif typ == "part_end" then
        close_file(write_file)
    elseif typ == "eof" then
        response.msg   = "upload success"
        break
    end
end

ngx.say(cjson.encode(response))