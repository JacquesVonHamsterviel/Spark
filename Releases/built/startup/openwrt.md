来自：https://blog.csdn.net/u012819339/article/details/51910146

openwrt的服务项都放在/etc/init.d/目录下，如果要将某个服务项添加到开机启动的话，在/etc/rc.d/目录下做一个连接就行了


在openwrt中加入自己的服务项，只需按照/etc/init.d/目录下其他脚本的形式依葫芦画瓢，填充以下方法就可以了，（用到什么方法就填充什么方法）

```
start   Start the service  
stop    Stop the service  
restart Restart the service  
reload  Reload configuration files (or restart if that fails)  
enable  Enable service autostart  
disable Disable service autostart  
```

比如加入一个 yourser 服务

```
#!/bin/sh /etc/rc.common

#service startup sequence
START=99

start() {
        #start your process with parameters in background
        /usr/bin/yourser -v para1 -C para2 &
}

stop() {
           killall yourser
}

```

获取权限并且启动服务：

```
chmod -R 777 /etc/init.d/yourser
/etc/init.d/yourser start
```


设置开机启动
```
/etc/init.d/yourser enable
```