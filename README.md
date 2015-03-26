# conoha-bootstrap
Chef-Soloを使ってConoHa VPSにRails環境を構築する。

# ConoHa VPSの準備
1. ConoHa VPSを作る。
2. テンプレートイメージのCentOS6.5

# ローカル側の準備
1. ConoHaコンソールから秘密鍵ダウンロード
2. ダウンロードした1234567-1.keyを~/.ssh/にコピー
3. 1234567-1.keyをリネーム->conoha_private_key
4. $ chmod 600 ~/.ssh/conoha_private_key
4. ~/.ssh/config
        Host conoha
          HostName	[VPSのIP]
          IdentityFile	~/.ssh/conoha_private_key
          User		root
5. ssh conoha

繋がることを確認

# Chef用ユーザの準備
1. ConoHaコンソールにrootでログイン
1. \# adduser chef
2. \# passwd chef
3. \# visudo
    1. root ALL=(ALL) ALL の下に
    2. chef ALL=(ALL) NOPASSWD:ALL
4. \# mkdir /home/chef/.ssh
5. \# cp ~/.ssh/authorized_keys /home/chef/.ssh/
6. \# cd /home/chef/.ssh
7. \# ls -la
        drwxr-xr-x 2 root root 4096  3月 27 01:29 2015 .
        drwx------ 3 chef chef 4096  3月 27 01:28 2015 ..
        -rw------- 1 root root  445  3月 27 01:29 2015 authorized_keys
8. \# chown chef:chef authorized_keys
9. \# chown chef:chef .
10. \# ls -la
11. \# chmod 600 authorized_keys
12. \# chmod 700 .
13. \# ls -la
        drwx------ 2 chef chef 4096  3月 27 01:29 2015 .
        drwx------ 3 chef chef 4096  3月 27 01:28 2015 ..
        -rw------- 1 chef chef  445  3月 27 01:29 2015 authorized_keys

# もいちどローカル側の準備
4. ~/.ssh/config
        Host conoha
          HostName	[VPSのIP]
          IdentityFile	~/.ssh/conoha_private_key
          User		chef
5. ssh conoha
6. $ who am i
        chef     pts/1        2015-03-27 01:41 (fl1-211-135-175-166.kyt.mesh.ad.jp)

chefユーザでSSHできた。

# ローカルでknife solo init
1. cd ~
2. knife solo init conoha-bootstrap
3. cd conoha-bootstrap
4. git init
5. git add .
6. git commit -m 'first commit'
7. git remote add origin git@github.com:naichilab/conoha-bootstrap.git
8. git push -u origin master

# knife solo prepare
1. knife solo prepare conoha
2. $ ssh conoha
3. $ chef-solo -v
Chef: 12.1.1
4. $ logout
5. git add nodes/conoha.json
6. git commit -m 'add node json'

# helloworld
1. knife cookbook create helloworld -o site-cookbooks/
2. site-cookbooks/helloworld/recipes/default.rb
log "Hello World!!"
3. nodes/conoha.json
"recipe[helloworld]"
4. knife solo cook conoha
表示を確認。






#
