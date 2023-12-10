# Cài đặt SSH cho Github

Hướng dẫn cho từng OS:
- [MacOS](#macos)
- [Windows](#windows)

Mục đích:  
Link git có 2 dạng:
- HTTPS: `https://github.com/account/project.git`
- SSH: `git@github.com:account/project.git`

Trong nhiều trường hợp dùng HTTPS sẽ tiện lợi, nhưng Github gần đây yêu cầu bảo mật nhiều lớp -> kém tiện lợi hơn xưa.  
Nếu sử dụng nhiều tài khoản Git trên cùng 1 machine cũng xảy ra nhiều phiền toái hơn.  
Cho nên có thể sử dụng SSH để thay thế cho HTTPS.  
Việc setup SSH hơi phức tạp ban đầu, nhưng chỉ thực hiện 1 lần duy nhất.

*Lưu ý: Các lệnh bên dưới phải thay bằng email cần sử dụng*

## MacOS

### 1. Kiểm tra SSH key có tồn tại chưa:
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys
```sh
# Lists the files in your .ssh directory, if they exist
ls -al ~/.ssh

# Nếu có một trong các key này thì có tồn tại rồi
# id_rsa.pub
# id_ecdsa.pub
# id_ed25519.pub
```
Nếu có tồn tại rồi thì đến thẳng **Bước 3**

### 2. Add new SSH key (nếu chưa có):
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
```sh
ssh-keygen -t ed25519 -C "nhannh@senspark.com"

# Sau đó có thể nhập passphrase nếu muốn
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases
```

#### Phải thêm auto-start ssh-agents (nếu chưa thêm)
Tạo file config vào thư mục ~/.ssh/ (Nếu chưa có file này)
```sh
open ~/.ssh/config
```

Nội dung cần thêm:  
Nếu ko dùng passphrase thì bỏ dòng `UseKeychain`  
Nếu lỗi UseKeychain thì thêm dòng `IgnoreUnknown UseKeychain`
```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

Add vào SSH-agents
```sh
# Nếu ko dùng passphrase thì bỏ option `--apple-use-keychain`
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### 3. Thêm SSH credential vào Github:
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=webui  
Lấy ra certificate key để input vào Github
```sh
# Read & Copy vào clipboard
pbcopy < ~/.ssh/id_ed25519.pub
```

### 4. Test:
### Nếu chưa add vào ssh-agents:
```sh
# Add key id_ed25519 vào agents
ssh-add ~/.ssh/id_ed25519

# Test connection
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Test login github với account default
ssh -T git@github.com

# Test login github với account nhannh
ssh -T git@github-nhannh
```

#### Format của github link:
`git@github-nhannh:org/project.git` => sử dụng user `nhannh`  
`git@github.com:org/project.git`    => sử dụng user `default`

#### Sử dụng SSH với multiple account:
https://gist.github.com/oanhnn/80a89405ab9023894df7

---

## WINDOWS

*Lưu ý: Windows sử dụng GitBash*

### 1. Kiểm tra SSH key có tồn tại chưa:
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys
```sh
# Lists the files in your .ssh directory, if they exist
ls -al ~/.ssh

# Nếu có một trong các key này thì có tồn tại rồi
# id_rsa.pub
# id_ecdsa.pub
# id_ed25519.pub
```
Nếu có tồn tại rồi thì đến thẳng **Bước 3**

### 2. Add new SSH key (nếu chưa có):
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
```sh
ssh-keygen -t ed25519 -C "nhannh@senspark.com"

# Sau đó có thể nhập passphrase nếu muốn (mật khẩu sẽ hỏi khi sử dụng ssh-agents)
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases
```

#### Thêm auto-start ssh-agents (nếu chưa thêm)
Tạo file .bashrc vào thư mục ~/ (Nếu chưa có file này)
```sh
cat ~/.bashrc
```

Nội dung file `.bashrc` cần bổ sung
```bash
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
```

```sh
# Apply file .bashrc
source ~/.bashrc
```

Add vào SSH-agents
```sh
ssh-add ~/.ssh/id_ed25519
```

### 3. Thêm SSH credential vào Github:
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account?tool=webui  
Lấy ra certificate key để input vào Github
```sh
# Read & Copy vào clipboard
cat ~/.ssh/id_ed25519.pub | clip
```

### 4. Test:
### Nếu chưa add vào ssh-agents:
```sh
# Add key id_ed25519 vào agents
ssh-add ~/.ssh/id_ed25519

# Test connection
ssh-keyscan github.com >> ~/.ssh/known_hosts

# Test login github với account default
ssh -T git@github.com

# Test login github với account nhannh
ssh -T git@github-nhannh
```

### Format của github link:
`git@github-nhannh:org/project.git` => sử dụng user `nhannh`  
`git@github.com:org/project.git`    => sử dụng user `default`

### Sử dụng SSH với multiple account:
https://gist.github.com/oanhnn/80a89405ab9023894df7
