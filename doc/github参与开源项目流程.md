##  Github Pull Request 流程简述


### GitHub参与开源项目要怎么操作？

1. 如果很久以前 fork 过，先在自己仓库的 `Settings` 里，翻到最下面，删除

2. 打开本项目主界面，点击 `Fork`，继续点击 `Create fork`

3. clone 仓库（你自己账号下） dev 分支到本地

   ```bash
   git clone <你的仓库 git 链接> -b dev
   ```
   
4. 下载预构建的第三方库

  请参考README来进行构建

5. 配置编程环境

   - 下载并安装 `Visual Studio Code`

6. 用Code打开项目

8. 到这里，你就可以愉快地进行开发了

9. 开发过程中，每一定数量，记得提交一个 commit, 别忘了写上 message

   假如你不熟悉 git 的使用，你可能想要新建一个分支进行更改，而不是直接提交在 `dev` 上

   ```bash
   git branch your_own_branch
   git checkout your_own_branch
   ```
   
   这样你的提交就能在新的分支上生长，不会受到 `dev` 更新的打扰

10. 完成开发后，推送你修改过的本地分支（以 `dev` 为例）到远程（fork 的仓库）

    ```bash
    git push origin dev
    ```
    
11. 打开本项目的主界面。提交一个 pull request，等待管理员通过。别忘了你是在 dev 分支上修改，别提交到 master 分支去了

12. 当项目原仓库出现更改（别人做的），你可能需要把这些更改同步到你的分支

    1. 关联原仓库

       ```bash
       git remote add upstream <原仓库 git 链接>
       ```
       
    2. 从原仓库拉取更新

       ```bash
       git fetch upstream
       ```
       
    3. 变基（推荐）或者合并修改
    
       ```bash
       git rebase upstream/dev # 变基
       ```
       
       或者

       ```bash
       git merge # 合并
       ```

    4. 重复上述 7, 8, 9, 10 中的操作