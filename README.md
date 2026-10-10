# homebrew-xfeichong

xfeichong 内网穿透 macOS 客户端的 Homebrew tap。

## 安装

```bash
brew install sayn443/xfeichong/xfeichong-client
```

安装完成即自动生成配置 `~/.xfeichong/config.json`（已存在不覆盖）。

## 使用

```bash
brew services start xfeichong-client   # 启动（后台常驻）
brew services stop xfeichong-client    # 停止
tail -f $(brew --prefix)/var/log/xfeichong-client.log   # 日志
```

修改 `~/.xfeichong/config.json`（appkey / local_port）保存后客户端自动接管，无需重启。
