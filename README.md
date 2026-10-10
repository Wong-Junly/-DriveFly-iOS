# DriveFly iOS

iOS 版与安卓版本使用同一个 Windows 接收端。iPhone 需要 iOS 16 或更新版本；游戏电脑需要原来的 DriveFly Windows 程序和 vJoy 驱动。

当前交付的是源码工程及 GitHub Actions 配置，还没有运行真实云端编译、签名安装或 iPhone 测试。推荐先用 GitHub Actions；需要时也能在自己的 Mac 或云 Mac 执行同一脚本。

## 1. 用 GitHub Actions 编译（推荐）

1. 在 [GitHub](https://github.com/) 创建自己的仓库，例如 `DriveFly-iOS`，勾选 **Add a README file** 后创建。公开或私有都可用；公开会公开源码，私有使用账号的 Actions 额度并可能有超额费用。[官方用量说明](https://docs.github.com/en/billing/concepts/product-billing/github-actions)
2. 把这个目录内的内容上传到仓库根目录，提交到默认分支（通常是 `main`）。仓库根目录应直接包含 `build-macos.sh`、`Package.swift`、`DriveFly.xcodeproj` 和 `.github/workflows/build-ios.yml`，不要再套 `DriveFlyIOS` 文件夹。聊天中提供的 `DriveFly-iOS-GitHub.zip` 已按这个结构打包。
3. 如果网页上传漏了 `.github`，用 **Add file → Create new file**，创建 `.github/workflows/build-ios.yml`，粘贴包里该文件内容并提交。
4. 打开仓库 **Actions → Build DriveFly iOS → Run workflow**，选择默认分支并运行。工作流必须先放在默认分支。[官方操作步骤](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)
5. 成功后，在运行摘要的 **Artifacts** 下载 **DriveFly-iOS-to-resign**，解压 ZIP 取得 `DriveFly-iOS.ipa`。产物保留 7 天，请及时下载。

工作流仅手动启动，使用 `macos-15` 标准编译机，先测试、后编译，失败停止；不需要配置 Apple 账号、密码、签名证书或自定义 Secrets。生成的 IPA 必须按下一节在 Windows 重签安装。它的完整性签名不包含 Apple 安装授权。

如果构建失败，打开 **Test and build iPhone app** 的日志，保存首个明确错误及其上下文。当前工作流已经静态核查，但尚未有真实 GitHub 构建结果。

## 备用：在自己的 Mac 或云 Mac 编译

选用已安装完整 Xcode 的 Mac，建议 Xcode 16 或更新版本，并能使用终端及下载生成的文件。云 Mac 无需连接你的 iPhone，也无需登录你的 Apple 账号。

把 `DriveFlyIOS` 工程目录传到自己的 Mac，打开终端并进入该目录。例如目录放在桌面时：

```bash
cd "$HOME/Desktop/DriveFlyIOS"
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-path
bash build-macos.sh
```

如果 `xcodebuild` 显示只有 Command Line Tools 或找不到 SDK，需要先在 Xcode“Settings → Locations → Command Line Tools”选择完整 Xcode，并完成该机器要求的首次启动设置。租用前确认服务提供这些条件。

脚本会运行纯 Swift 核心测试，再使用 `generic/platform=iOS` 编译完整真机 App。全部成功后生成：

```text
DriveFlyIOS/build/DriveFly-iOS.ipa
```

把 IPA 下载回 Windows。脚本的本地完整性签名不包含 Apple 安装授权，**这个 IPA 不能直接点开安装，必须在下一步重新签名**。构建失败时保留原有 IPA；请保存终端错误用于排查。

## 2. 在 Windows 重签并安装

按 [AltStore 官方 Windows 安装指南](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)准备软件。最小步骤如下：

1. 从 [AltStore 官网](https://altstore.io/)下载 Windows 版 AltServer，安装后运行。官网要求 Windows 10 或更新版本。
2. 安装官方指南提供的 Apple 官网版 [iTunes 64 位](https://www.apple.com/itunes/download/win64)和 [iCloud 安装程序](https://updates.cdn-apple.com/2020/windows/001-39935-20200911-1A70AA56-F448-11EA-8CC0-99D41950005E/iCloudSetup.exe)。这里采用 AltServer 指南所需的桌面版组件；Apple 新版 iCloud 的常规下载页目前默认提供 Microsoft Store 版。如果已使用 Store 版，请先阅读 [AltStore 的兼容处理说明](https://faq.altstore.io/altstore-classic/troubleshooting-guide#windows-i-need-to-use-the-windows-store-icloud)。
3. 用 USB 把 iPhone 连接到 Windows，解锁手机并选择“信任此电脑”。确认 iTunes 能看到手机；按指南登录 iTunes，启用手机的 Wi-Fi 同步。首次安装可保持 USB 连接。
4. 按住 **Shift**，点击右下角 AltServer 托盘图标，选择 **Sideload .ipa…**，选择你的手机和 `DriveFly-iOS.ipa`。此功能可以直接安装自己的 IPA，无需先安装 AltStore App。[官方功能说明](https://faq.altstore.io/release-notes/altserver)
5. 在 AltServer 自己的登录窗口使用本人的 Apple 账号，完成它要求的验证。账号及验证信息不用提供给本聊天或云 Mac。
6. 手机上打开“设置 → 通用 → VPN 与设备管理”，信任相应开发者账号。开启“设置 → 隐私与安全性 → 开发者模式”，按手机提示重启并确认。[Apple 开发者模式说明](https://developer.apple.com/news/?id=r1sz7dke)

免费 Apple 账号的开发签名配置 7 天后过期；到期前用本机 AltServer 按相同步骤重新安装。Apple 限制每台设备最多 3 个开发 App，账号同时最多 10 个 App ID。[Apple 官方限制](https://developer.apple.com/help/account/basics/about-your-developer-account)

如果 AltServer 找不到手机，先保持 USB 连接，确认信任关系及 Apple 移动设备组件已安装；如果重签失败，保存其错误码，按 [官方排错指南](https://faq.altstore.io/altstore-classic/troubleshooting-guide)处理。文档确认的是重签路径，尚未验证这个工程生成的 IPA 在你的 iOS 版本上的安装结果。

## 3. 连接 Windows 游戏

1. 安装并配置 vJoy 设备 1，启用 X、Y、Z、Rx、Ry 轴及 32 个按钮，启动原来的 `DriveFlyDesktop.exe`。
2. iPhone 与电脑连接同一个局域网；在 DriveFly 设置中输入电脑的局域网 IPv4 地址，例如 `192.168.1.10`，点击“连接并返回”。首次连接允许本地网络访问。电脑防火墙需允许接收 UDP 7001。[Apple 本地网络权限说明](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy)
3. 横握手机，保持舒适的自然姿势，点击“校准回中”。只有收到电脑回复后，界面才显示“已连接”。
4. 选择赛车或飞机模式，在游戏设置中把 vJoy 轴绑定到对应操作。先低速检查每个轴的方向，游戏需要时勾选反转。

| 模式 | X | Y | Z | Rx | Ry |
| --- | --- | --- | --- | --- | --- |
| 赛车 | 转向 | 油门 | 刹车 | 离合 | 归零 |
| 飞机 | 横滚 | 油门 | 俯仰 | 方向舵 | 襟翼 |

赛车踏板松手归零；飞行油门和襟翼保持滑块位置，左右方向舵按钮松手回中。飞机横滚和俯仰满量程为 ±30°，赛车转向满量程可在设置中调整。

切换模式、进入设置、翻转横屏方向、切到后台或连接中断时会清空输入，恢复后重新校准并调整油门。电脑连续 500 毫秒未收到有效数据也会归零；手机在前台控制时保持屏幕常亮。

云 Mac 解决的是 Apple SDK 编译；本机 Windows 负责重签并连接自己的 iPhone。云 Mac 没有 USB 连接不能保证免费 Personal Team 在 Xcode 中直接安装到远程手机。如果已有付费 Apple Developer Program，可另用注册手机 UDID、分发证书和 Ad Hoc provisioning profile 导出安装包；本工程未配置这条发行路径。[Apple Ad Hoc 要求](https://developer.apple.com/help/account/provisioning-profiles/create-an-ad-hoc-provisioning-profile/)

尚未在真实 iPhone 或游戏中检查陀螺仪方向、延迟和断线行为；首次使用应先在 vJoy 测试界面检查轴与按钮。

此客户端按 MIT 许可开源，见 `LICENSE`；沿用 [DriveLink](https://github.com/DevBoiAgru/DriveLinkMobile) 的 Windows 通信协议。UDP 仅用于可信局域网，未加密、未认证，不要把 7001 端口开放到互联网。
