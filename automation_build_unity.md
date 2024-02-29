# Build unity
- Cách 1: Sử dụng web
  
Bước 1: Đảm bảo sau khi pull source về, mở project không gặp lỗi và build tay thành công trên unity version 2022.3.12f1 trên máy build  
Bước 2: Truy cập trang web http://192.168.1.240:3000/  
Bước 3: Nhập đầy đủ input và nhấn submit  
Bước 4: Đợi alert của web hoặc notification từ slack và vào file share lấy file build về  
  
- Cách 2: Sử dụng cmd
  
Bước 1: Đảm bảo sau khi pull source về, mở project không gặp lỗi và build tay thành công trên unity version 2022.3.12f1 trên máy build  
Bước 2: ssh vào máy build
```bash
ssh Senspark@192.168.1.240
```
Bước 3: chạy file bash script build.sh với những tham số, tên project, tên branch (để pull source), platform build:Android/WebGL (https://docs.unity3d.com/ScriptReference/BuildTarget.html), nếu build android thì cần thêm những tham số sau mật khẩu keystore, tên alias, mật khẩu keyalias, build bundle không:true/false  
Ex:  
```powershell
"C:\Program Files\Git\bin\bash.exe" build.sh bombcrypto-client DevNhan_prod2 WebGL
"C:\Program Files\Git\bin\bash.exe" build.sh tank1 DevTuan Android passKeyStore nameAlias passAlias true
```
  
Bước 4: Đợi notification từ slack trong chanel unity-build và vào file share của máy build lấy file về
`Open finder->Go->Connect to sever->Browse->build-unity->Connect As->Connect`

# File build script (BuildScript.cs)
```cs
using UnityEditor;
using UnityEngine;

public class BuildScript : MonoBehaviour
{
    static void PerformBuild()
    {
        var projectName = "@PROJECTNAME";
        var buildTarget = "@BUILDTARGET";
        // tham số có thể chỉnh: https://docs.unity3d.com/ScriptReference/PlayerSettings.html
        PlayerSettings.SplashScreen.showUnityLogo = false;
        PlayerSettings.Android.keystorePass = "@KEYSTOREPASS";
        PlayerSettings.Android.keyaliasName = "@KEYALIASNAME";
        PlayerSettings.Android.keyaliasPass = "@KEYALIASPASS";
        // tắt bật build app bundle 
        EditorUserBuildSettings.buildAppBundle = @BUILDBUNDLE;

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

        // chỉnh tên file và chỗ lưu file cho từng platform
        if (buildTarget == "Android") {
            var versionCode = PlayerSettings.Android.bundleVersionCode;
            buildPlayerOptions.target = BuildTarget.Android;
            if (EditorUserBuildSettings.buildAppBundle) {
                buildPlayerOptions.locationPathName = $"C:/Users/Senspark/Project/builds/{projectName}/{versionCode}.aab";
            }
            else {
                buildPlayerOptions.locationPathName = $"C:/Users/Senspark/Project/builds/{projectName}/{versionCode}.apk";
            }
        }
        else if (buildTarget == "WebGL") {
            buildPlayerOptions.target = BuildTarget.WebGL;
            buildPlayerOptions.locationPathName = $"C:/Users/Senspark/Project/builds/{projectName}";
        }

        // build
        BuildPipeline.BuildPlayer(buildPlayerOptions);
    }
}
```

# File build.sh trên máy build
```bash
# "C:\Program Files\Git\bin\sh.exe" build.sh project_name branch_name platform_build keystore_pass alias_name key_alias build_bundle
set -e
arg1=$1
arg2=$2
arg3=$3
arg4=$4
arg5=$5
arg6=$6
arg7=$7

# kiểm tra tồn tại project hay chưa
FILE="C:\\Users\\Senspark\\Project\\source\\$arg1"
if [ ! -d "$FILE" ]; then
echo Not have this project
exit 1
fi

echo cd project $arg1
cd "C:\\Users\\Senspark\\Project\\source\\$arg1"

echo Git checkout $arg2 and pull
git reset --hard
branch=$(git symbolic-ref --short HEAD)
if [ ! $branch == $arg2 ]; then
git checkout $arg2
fi
git pull

FILE="Assets/Editor"
if [ ! -d "$FILE" ]; then
mkdir "Assets\Editor"
fi
# chuyển file build trên máy sang thư mục build của project
"C:\Program Files\Git\usr\bin\cp.exe" "C:/Users/Senspark/BuildScript.cs" "Assets/Editor/"

# thay tham số tham số truyền vào vào từng vị trí trong file build
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@PROJECTNAME/$arg1/g" "Assets/Editor/BuildScript.cs"
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@BUILDTARGET/$arg3/g" "Assets/Editor/BuildScript.cs"
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@KEYSTOREPASS/$arg4/g" "Assets/Editor/BuildScript.cs"
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@KEYALIASNAME/$arg5/g" "Assets/Editor/BuildScript.cs"
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@KEYALIASPASS/$arg6/g" "Assets/Editor/BuildScript.cs"
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@BUILDBUNDLE/$arg7/g" "Assets/Editor/BuildScript.cs"

echo Cleaning Up Build Directory
# xoá thư mục project trong folder build
rm -rf "../../builds/$arg1"
echo Starting Build Process
"C:\Program Files\Unity\Hub\Editor\2022.3.12f1\Editor\Unity.exe" -quit -ignorecompilererrors -batchmode -projectPath "../$arg1" -executeMethod BuildScript.PerformBuild
echo Ended Bulid Process

# Nếu thấy có thư mục project trong folder build thì notification thành công lên slack
FILE="../../builds/$arg1"
if [ -d "$FILE" ]; then
    curl -d "text=:white_check_mark: Build project $arg1 branch $arg2 platform $arg3 done." -d "channel=unity-build" -H \
    "Authorization: Bearer xoxb-token-of-just-post-bot-when-create-bot-app" -X POST https://slack.com/api/chat.postMessage
    exit 0
else
    curl -d "text=:x: Build project $arg1 branch $arg2 platform $arg3 error." -d "channel=unity-build" -H \
    "Authorization: Bearer xoxb-token-of-just-post-bot-when-create-bot-app" -X POST https://slack.com/api/chat.postMessage
    exit 1
fi
```
