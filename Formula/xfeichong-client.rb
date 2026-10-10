class XfeichongClient < Formula
  desc "xfeichong 内网穿透客户端：本地 TCP 转发到 NAT 映射地址"
  homepage "https://xfeichong.com"
  url "https://raw.githubusercontent.com/sayn443/homebrew-xfeichong/main/tarball/xfeichong-client-1.0.0.tar.gz"
  sha256 "1fc876b9596e190529bd538efeabf458ae763613e875267ab83382314ca19456"
  license "MIT"
  version "1.0.0"

  depends_on "python@3.14"

  def install
    libexec.install "natmap_client.py", "config.json"
    # 通过包装脚本固定使用 brew 的 python，避免依赖系统 python
    (bin/"xfeichong-client").write <<~EOS
      #!/bin/bash
      exec "#{Formula["python@3.14"].opt_bin}/python3" -u "#{libexec}/natmap_client.py" "$@"
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
    EOS
  end
end
