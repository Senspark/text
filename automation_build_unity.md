# Hướng dẫn automation build unity
- Cách 1: Sử dụng web
  
Bước 1: Đảm bảo sau khi pull source về, mở project không gặp lỗi và build tay thành công trên unity version 2022.3.12f1 trên máy build  
Bước 2: Truy cập trang web http://192.168.1.240:300. /  
Bước 3: Nhập đầy đủ input bắt buộc và nhấn submit  
Bước 4: Đợi thông báo của web hoặc notification từ slack và vào file share lấy file build về `Open finder->Go->Connect to sever->Browse->build-unity->Connect As->Connect`  
Bước 5: Nếu build bundle có thể upload file vừa builld lên internal bằng nút Upload aab (đợi thông báo để biết upload thành công hay thất bại)          
  
- Cách 2: Sử dụng cmd
  
Bước 1: Đảm bảo sau khi pull source về, mở project không gặp lỗi và build tay thành công trên unity version 2022.3.12f1 trên máy build  
Bước 2: ssh vào máy build
```bash
ssh Senspark@192.168.1.240
```
Bước 3: chạy file bash script build.sh với những tham số, tên project, tên branch (để pull source), platform build:Android/WebGL (https://docs.unity3d.com/ScriptReference/BuildTarget.html), nếu build android thì cần thêm những tham số sau mật khẩu keystore, tên alias, mật khẩu keyalias, build bundle không:true/false, tên version android bundle, code version android bundle  
Ex:  
```powershell
"C:\Program Files\Git\bin\bash.exe" build.sh bombcrypto-client DevNhan_prod2 WebGL
"C:\Program Files\Git\bin\bash.exe" build.sh tank1 DevTuan Android passKeyStore nameAlias passAlias true 2.7.1 201685145
```
Lưu ý: Nếu không truyền 3 tham số build bundle không:true/false tên version android bundle, code version android bundle thì sẽ build bằng trạng thái hiện tại trên unity  
  
Bước 4: Đợi notification từ slack trong chanel unity-build và vào file share của máy build lấy file về
`Open finder->Go->Connect to sever->Browse->build-unity->Connect As->Connect`

# Cách hoạt động
Cơ bản của automation build là sử dụng câu lệnh trên command line để unity chạy một static function build đặt trong folder Editor như sau: (file mẫu build nằm trong này  https://docs.unity3d.com/Manual/EditorCommandLineArguments.html)  
```bash
"C:\Program Files\Unity\Hub\Editor\2022.3.12f1\Editor\Unity.exe" -quit -ignorecompilererrors -batchmode -projectPath "../$arg1" -executeMethod BuildScript.PerformBuild
```
Từ đó tạo 1 file bash script để truyền thêm tham số mình cần từ command line và thực hiện 1 số thao tác khác    
Về cơ bản file bash script làm những việc như sau:  
`Nhận tham số truyền vào-> Kiểm tra tồn tại project-> Checkout branch và pull source về-> Chuyển file mẫu build có sẵn từ trên máy build vào project-> Thay tham số từ command line vào file build-> Xoá thư mục build trước đó-> Chạy lệnh build unity-> Thông báo lên slack`  
Thông báo lên slack thì cẩn key của một con bot slack hay slack app (https://api.slack.com/tutorials/tracks/posting-messages-with-curl)  
Để lấy file vừa build về máy cá nhân thì sử dụng share folder của windows  
Để việc build được dễ dàng hơn nên tạo thêm 1 web nhập tham số truyền vào cho dễ dàng, web sẽ lấy input và chạy lệnh cho mình  
Muốn up file lên internal thì sử dụng javascipt gọi API từ google play.  

# File build script (BuildScript.cs)
```cs
using System.IO;

using UnityEditor;
using UnityEditor.Build.Reporting;

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
        var bundleVersion = "@BUNDLEVERSIONNAME";
        var bundleVersionCode = "@BUNDLEVERSIONCODE";

        if (bundleVersion != "") {
            PlayerSettings.bundleVersion = bundleVersion;
        }
        if (bundleVersionCode != "") {
            PlayerSettings.Android.bundleVersionCode = int.Parse(bundleVersionCode);
        }
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
        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
        BuildSummary summary = report.summary;
        
        if (summary.result == BuildResult.Succeeded)
        {
            if (buildTarget == "Android" && EditorUserBuildSettings.buildAppBundle) {
                // build thành công, nếu build bundle thì lưu dữ liệu cho việc upload
                var sr = File.CreateText($"C:/Users/Senspark/Project/builds/{projectName}/upload.txt");
                sr.WriteLine ($"package_name: {Application.identifier}");
                sr.WriteLine ("file_aab: " + $"{PlayerSettings.Android.bundleVersionCode}.aab");
                sr.Close();
            }
        }
    }
}
```

# File build.sh trên máy build
```bash
# "C:\Program Files\Git\bin\sh.exe" build.sh project_name branch_name platform_build keystore_pass alias_name key_alias build_bundle version_name version_code
set -e
arg1=$1
arg2=$2
arg3=$3
arg4=$4
arg5=$5
arg6=$6
arg7=$7
arg8=$8
arg9=$9

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
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@BUNDLEVERSIONNAME/$arg8/g" "Assets/Editor/BuildScript.cs"
"C:\Program Files\Git\usr\bin\sed.exe" -i -e "s/@BUNDLEVERSIONCODE/$arg9/g" "Assets/Editor/BuildScript.cs"

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
