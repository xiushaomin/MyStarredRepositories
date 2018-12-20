import Foundation

var templete = """
# 我的 Star

由于习惯性看到好的仓库都想Star一下。

但是发现想用的时候可能记不起，所以简单写了小脚本自动生成 README

如果有需要可以跑一下脚本哟！！

```
$ git clone https://github.com/xiushaomin/MyStarredRepositories.git
$ cd to clone folder
$ swift ./MyStarredRepositories.swift
$ 输入Github用户名和密码
$ 等待一会

```

## Creat By Script

| Repositories URL | Description |
| ---- | ---- |
"""

let itemString = "\n| [%@](%@) | %@ |"


print("输入你的Github用户名:")
let userName = readLine()
if userName == nil {
    print("账号不能为空")
    exit(0)
}

print("输入你的Github密码:")
let passWord = readLine()
if passWord == nil {
    print("密码不能为空")
    exit(0)
}


let userNamePassWord = String(format: "%@:%@", userName!, passWord!)
let API = String(format: "https://api.github.com/users/%@/starred?page=1&per_page=100", userName!)



if let url = URL(string: API) {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    guard let userNameData = userNamePassWord.data(using: .utf8) else {
        exit(0)
    }
    
    let userNameBase64 = userNameData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    let userNameAuth = String(format:"BASIC %@", userNameBase64)
    request.setValue(userNameAuth, forHTTPHeaderField: "Authorization")
    
    let semaphore = DispatchSemaphore(value: 0)
    print("开始创建MD~")
    let starTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if let data = data {
            do {
                guard let starArray = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Array<Dictionary<String, Any>>, starArray.count > 0 else {
                    return
                }
                for item in starArray {
                    if let name = item["name"] as? String, let url = item["url"] as? String, let desc = item["description"] as? String {
                        templete += String(format: itemString, name, url, desc)
                    }
                }
                
                do {
                    try templete.write(toFile: FileManager.default.currentDirectoryPath.appendingFormat("%@", "/README.md"), atomically: false, encoding: .utf8)
                } catch {
                    print(error)
                }
                
                print("🎉🎉 创建MD成功!! ")
            } catch {
                print(error)
            }
        }
        semaphore.signal()
    }
    
    starTask.resume()
    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
}




