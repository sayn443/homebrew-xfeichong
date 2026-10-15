class XfeichongClient < Formula
  desc "xfeichong 内网穿透客户端：本地 TCP 转发到 NAT 映射地址"
  homepage "https://xfeichong.com"
  url "https://raw.githubusercontent.com/sayn443/homebrew-xfeichong/main/tarball/xfeichong-client-1.0.1.tar.gz"
  sha256 "5d85f215b42dbe9e58cec9fccac8468a84a99e7b044f764ec02c32b106b64322"
  license "MIT"
  version "1.0.1"

  # 纯标准库脚本，直接用 macOS 自带的 python3（/usr/bin/python3，CLT 附带），
  # 不引入 brew 的 python@3.14 及其 6 个依赖（ca-certificates/openssl/readline/sqlite/xz）
  uses_from_macos "python"

  def install
    libexec.install "natmap_client.py", "config.json"
    # 使用系统 python3；brew 用户必然已装 CLT（brew 本身依赖它），/usr/bin/python3 必然存在
    (bin/"xfeichong-client").write <<~EOS
      #!/bin/bash
      exec /usr/bin/python3 -u "#{libexec}/natmap_client.py" "$@"
    EOS
  end

  service do
    run [opt_bin/"xfeichong-client"]
    run_type :immediate
    keep_alive true
    log_path var/"log/xfeichong-client.log"
    error_log_path var/"log/xfeichong-client.log"
  end

  def post_install
    (var/"log").mkpath
    # 安装即初始化：把捆绑的配置模板放到 ~/.xfeichong/config.json（已存在则不覆盖）
    begin
      config_dir = Pathname.new(ENV["HOME"])/".xfeichong"
      config_dir.mkpath
      target = config_dir/"config.json"
      unless target.exist?
        cp libexec/"config.json", target
        ohai "已生成配置文件: #{target}"
      end
    rescue StandardError => e
      opoo "未能自动创建配置（#{e.message}），请手动运行: xfeichong-client init"
    end
  end

  def caveats
    <<~EOS
      配置文件: ~/.xfeichong/config.json（安装时已自动生成，默认 appkey 为本项目内置）
      更换 appkey 后无需重启，客户端会自动接管
      启动服务: brew services start xfeichong-client
      查看日志: tail -f #{var}/log/xfeichong-client.log
      依赖说明: 使用 macOS 自带 python3（需 Xcode 命令行工具；若缺失执行 xcode-select --install）
    EOS
  end
end
