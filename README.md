# or_video_live
a video server,can upload file which use openresty.<br>
(1)download rtmp module:
```
git clone https://github.com/arut/nginx-rtmp-module
```
(2)nginx configure:
```
./configure --prefix=/home/openresty \
            --with-luajit \
            --without-http_redis2_module \
            --with-http_iconv_module \
            --with-http_flv_module \
            --with-http_mp4_module  \
            --with-http_ssl_module \
            --with-debug \
            --add-module=../nginx-rtmp-module \                 --with-http_ssl_module
```
(3)before run nginx server,It is need to create some file:
```
mkdir /var/www
cp /root/nginx/nginx-rtmp-module/stat.xsl /var/www/
#save video files
mkdir /var/mp4s/
mkdir /var/flvs/
```

for reference this article：[https://www.leaseweb.com/labs/2013/11/streaming-video-demand-nginx-rtmp-module/](https://www.leaseweb.com/labs/2013/11/streaming-video-demand-nginx-rtmp-module/)

(4)upload_video API<br>
```
    #using curl tool test
    curl  -F "filename=@test.mp4" 'http://<ip:port>/api/upload_video.json?filename=test.mp4'
```
Can only upload mp4 and flv file.