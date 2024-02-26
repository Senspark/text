# Build unity
Bước 1: tạo file build script trong thư mục Asset/Editor và commit lên, lưu ý đúng tên thư mục Editor, không sẽ xảy ra lỗi  
Bước 2: Đảm bảo build tay trên unity version 2022.3.12f1 thành công trên máy build  
Bước 3: ssh vào máy build
```bash
ssh Senspark@192.168.1.240
```
Bước 4: chạy file bash script build.sh với 3 tham số, tên project, tên branch (để pull source), mật khẩu keystore cũng như keyalias
```powershell
C:\Users\Senspark>"C:\Program Files\Git\bin\sh.exe" build.sh project_name branch_name keystore_pass
```
Bước 5: Đợi notification từ slack trong chanel unity-build và vào file share của máy build lấy file về
`Open finder->Go->Connect to sever->Browse->build-unity->Connect As->Connect`

# File mẫu build script của tank1 (BuildScript.cs)
```cs
using UnityEditor;
using UnityEngine;

public class BuildScript : MonoBehaviour
{
    static void PerformBuild()
    {
        var password = "@PASSWORD";
        PlayerSettings.SplashScreen.showUnityLogo = false;
        PlayerSettings.Android.keyaliasPass = password;
        PlayerSettings.Android.keystorePass = password;

        var versionCode = PlayerSettings.Android.bundleVersionCode;

        string[] defaultScence = { "Assets/Scenes/GameSplashLayer.unity", "Assets/Scenes/MenuScene.unity", // chỉnh lại list scene
                                    "Assets/Scenes/BoosterScene.unity", "Assets/Scenes/GameScene.unity",
                                    "Assets/Scenes/ResultLayer.unity" };
        BuildPipeline.BuildPlayer(defaultScence,  $"C:/Users/Senspark/Project/builds/tank1/{versionCode}.apk"
            , BuildTarget.Android, BuildOptions.None); // chỉnh lại project name
    }
}
```

# File build.sh trên máy build
```bash
set -e #để khi gặp error sẽ dừng
arg1=$1
arg2=$2
arg3=$3
if [ $# -le 2 ]; then #kiểm tra số lượng tham số truyền vào
echo Expect more EmptyValue
exit 0
fi

if [ "$arg1" != "tank1" ]; then #kiểm tra tên project
echo Not have this project
exit 0
fi

cd "Project/source/$arg1" #cd vào project

echo Git checkout $arg2 and pull #pull source mới nhất về
git reset --hard
git checkout $arg2
git pull

"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@PASSWORD/$arg3/g" "Assets/Editor/BuildScript.cs" #thay đổi @PASSWORD trong file BuildScript.cs thành password được truyền vào

echo Cleaning Up Build Directory
rm -rf "../../builds/$arg1"
echo Starting Build Process
"C:\Program Files\Unity\Hub\Editor\2022.3.12f1\Editor\Unity.exe" -quit -batchmode -projectPath "../$arg1" -executeMethod BuildScript.PerformBuild #dùng unity chạy file BuildScript.cs để build
echo Ended Bulid Process

curl -d "text=Build project $arg1 done." -d "channel=unity-build" -H "Authorization: Bearer xoxb-token-of-just-post-bot-when-create-bot-app" -X POST https://slack.com/api/chat.postMessage #dùng slack app just-post-bot để tạo message thông báo vào chanel unity-build
```
