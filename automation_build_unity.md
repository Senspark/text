# Build unity
Bước 1: Tạo file build script như mẫu trong thư mục Asset/Editor và commit lên, lưu ý đúng tên thư mục Editor, không sẽ xảy ra lỗi  
Bước 2: Đảm bảo sau khi pull source về, mở project không gặp lỗi và build tay thành công trên unity version 2022.3.12f1 trên máy build  
Bước 3: ssh vào máy build
```bash
ssh Senspark@192.168.1.240
```
Bước 4: chạy file bash script build.sh với 4 tham số, tên project, tên branch (để pull source), mật khẩu keystore cũng như keyalias (nếu build WebGL không cần key store có thể nhập bừa bất kì kí tự nào), platform build:Android/WebGL (https://docs.unity3d.com/ScriptReference/BuildTarget.html)  
```powershell
"C:\Program Files\Git\bin\bash.exe" build.sh project_name branch_name keystore_pass build_platform
```
Ex: "C:\Program Files\Git\bin\bash.exe" build.sh bombcrypto-client DevTuan keystore_pass WebGL  
  
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
        var projectName = "@PROJECTNAME";
        var buildTarget = "@BUILDTARGET";
        // tham số có thể chỉnh: https://docs.unity3d.com/ScriptReference/PlayerSettings.html
        PlayerSettings.SplashScreen.showUnityLogo = false;
        PlayerSettings.Android.keyaliasPass = password;
        PlayerSettings.Android.keystorePass = password;

        // lấy danh sách sreen trong build setting
        int sceneCount = UnityEngine.SceneManagement.SceneManager.sceneCountInBuildSettings;     
        string[] scenes = new string[sceneCount];
        for( int i = 0; i < sceneCount; i++ )
        {
            scenes[i] = UnityEngine.SceneManagement.SceneUtility.GetScenePathByBuildIndex(i);
        }

        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions();
        buildPlayerOptions.scenes = scenes;
        buildPlayerOptions.options = BuildOptions.None;

        if (buildPlayerOptions.target == BuildTarget.Android) {
            var versionCode = PlayerSettings.Android.bundleVersionCode;
            buildPlayerOptions.target = BuildTarget.Android;
            buildPlayerOptions.locationPathName = $"C:/Users/Senspark/Project/builds/{projectName}/{versionCode}.apk";
        }
        else if (buildTarget == "WebGL") {
            buildPlayerOptions.target = BuildTarget.WebGL;
            buildPlayerOptions.locationPathName = $"C:/Users/Senspark/Project/builds/{projectName}";
        }

        BuildPipeline.BuildPlayer(buildPlayerOptions);
    }
}
```

# File build.sh trên máy build
```bash
set -e #để khi gặp error sẽ dừng
arg1=$1
arg2=$2
arg3=$3
arg4=$4
if [ $# -lt 4 ]; then #kiểm tra số lượng tham số truyền vào
echo Expect more EmptyValue
exit 0
fi

FILE="Project/source/$arg1"
if [ ! -d "$FILE" ]; then #kiểm tra tồn tại project hay không
echo Not have this project
exit 0
fi

cd "Project/source/$arg1" #cd vào project

echo Git checkout $arg2 and pull #pull source mới nhất về
git reset --hard
git checkout $arg2
git pull

#thay đổi @PROJECTNAME, @PASSWORD, @BUILDTARGET trong file BuildScript.cs thành tham số được truyền vào
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@PROJECTNAME/$arg1/g" "Assets/Editor/BuildScript.cs"
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@PASSWORD/$arg3/g" "Assets/Editor/BuildScript.cs"
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@BUILDTARGET/$arg4/g" "Assets/Editor/BuildScript.cs"

echo Cleaning Up Build Directory
rm -rf "../../builds/$arg1"
echo Starting Build Process
#dùng unity chạy file BuildScript.cs để build
"C:\Program Files\Unity\Hub\Editor\2022.3.12f1\Editor\Unity.exe" -quit -batchmode -projectPath "../$arg1" -executeMethod BuildScript.PerformBuild 
echo Ended Bulid Process

#dùng slack app just-post-bot để tạo message thông báo vào chanel unity-build
FILE="../../builds/$arg1"
if [ -d "$FILE" ]; then
    curl -d "text=:white_check_mark: Build project $arg1 done." -d "channel=unity-build" -H \
    "Authorization: Bearer xoxb-token-of-just-post-bot-when-create-bot-app" -X POST https://slack.com/api/chat.postMessage
else
    curl -d "text=:x: Build project $arg1 error." -d "channel=unity-build" -H \
    "Authorization: Bearer xoxb-token-of-just-post-bot-when-create-bot-app" -X POST https://slack.com/api/chat.postMessage
fi
```
