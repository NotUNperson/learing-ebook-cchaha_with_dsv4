# 02-04 COPY 与 ADD 指令

## 本节你会学到什么

- 掌握 COPY 指令的用法和最佳实践
- 理解 ADD 和 COPY 的区别，知道什么时候用哪个
- 理解 Docker 层缓存机制对 COPY 顺序的影响
- 能够正确组织 COPY 顺序以最大化缓存命中率

## 正文

### COPY：搬家公司

COPY 指令就是把宿主机上的文件"搬"到镜像里。就像搬家公司：从你家（宿主机）搬东西到新家（镜像）。

```dockerfile
COPY 源路径 目标路径
COPY package.json /app/package.json
COPY . /app/
```

源路径是相对 Dockerfile 所在目录（即构建上下文），目标路径是镜像里的绝对路径。目标路径如果不存在，Docker 会自动创建。

### ADD：搬家+代购+拆快递

ADD 是 COPY 的"加强版"。除了搬文件，它还有两个额外功能：

1. **自动解压**：如果源文件是 tar.gz/tar.xz 等压缩包，ADD 会自动解压到目标目录。
2. **支持 URL**：源路径可以是一个 URL，Docker 会下载该文件到镜像中。

但这正是 ADD 被 Docker 官方"不推荐"的原因——能力越大，行为越不可控。你以为只是拷个文件，结果它悄悄帮你解压了；你以为只是下载个东西，结果过了几个月那个 URL 失效了。

所以 Docker 官方的建议是：**能用 COPY 就用 COPY，只在确实需要自动解压功能时才用 ADD。**

```dockerfile
# 推荐：用 COPY 复制普通文件
COPY myapp.tar.gz /tmp/

# 不推荐但可以接受：你真的需要自动解压
ADD myapp.tar.gz /app/

# 不推荐：用 ADD 下载文件（改用 RUN wget/curl）
ADD https://example.com/file.tar.gz /tmp/
# 更好的做法：
RUN curl -fsSL https://example.com/file.tar.gz -o /tmp/file.tar.gz
```

用 RUN curl 的好处是：1）可以在同一层里清理下载的临时文件；2）可以验证校验和；3）行为明确可控。

### COPY 顺序的讲究：缓存优化

这是本节的精华。Docker 在构建时，会检查每一行指令的"输入"是否发生了变化。对于 COPY 指令，"输入"就是被复制的文件内容。如果文件没变，Docker 就直接用缓存。

利用这个特性，我们可以先 COPY 不常变的文件（依赖声明），再 COPY 常变的文件（源码）：

```dockerfile
# 反例：先拷全部，每次改一行代码缓存全失效
COPY . /app/
RUN npm install

# 正例：先拷依赖声明，安装依赖（缓存友好），再拷源码
COPY package.json package-lock.json /app/
RUN npm install
COPY . /app/
```

用"快递配送"来类比：你的代码有两类文件——依赖声明文件（package.json）变化很少，源码文件（.js）变化很频繁。

反例的做法是"把整个箱子送到仓库，然后在仓库里拆包"——每次哪怕只改了一个 JS 文件，整个快递箱都得重新送。正例的做法是"先把采购清单送过去，采购完成、东西放好，最后再把内容送过去"——名单不常变，所以采购环节几乎总是命中缓存。

这个技巧能显著加快构建速度，尤其在 CI/CD 流水线中。当 `npm install` 耗时 2 分钟而你一天改 20 次代码时，这个优化一天就能省 38 分钟。

### 一个完整示例

假设你有这样一个目录结构：

```
project/
  Dockerfile
  package.json
  package-lock.json
  src/
    index.js
    utils.js
```

正确的 Dockerfile 写法：

```dockerfile
FROM node:20-alpine

WORKDIR /app

# 第一步：先拷依赖文件（不常变）
COPY package.json package-lock.json ./

# 第二步：安装依赖（这层会被缓存，直到依赖变化）
RUN npm ci --only=production

# 第三步：最后拷源码（常变，但不影响上面两层）
COPY src/ ./src/

CMD ["node", "src/index.js"]
```

### 目录结构的注意事项

COPY 有个容易踩的坑：目标路径结尾是否有 `/` 决定了行为：

```dockerfile
COPY mydir /app/dir     # 把 mydir 复制为 /app/dir（如果 /app/dir 不存在，创建它并复制内容进去）
COPY mydir /app/dir/    # 把 mydir 复制到 /app/dir/ 下面（要求 /app/dir 必须存在）
```

简单记忆：目标路径加 `/` 表示"放到这个目录下"，不加 `/` 表示"复制并重命名为这个名字"。

## 动手试试

创建一个简单的 Node.js 项目（至少包含 package.json 和一个 index.js），写两个版本的 Dockerfile：

1. 版本 A：`COPY . /app/` 然后 `RUN npm install`
2. 版本 B：先 `COPY package*.json /app/`，再 `RUN npm install`，最后 `COPY . /app/`

分别构建两次（第一次构建，随便改一个 JS 文件，第二次构建），观察第二次构建时哪个版本的缓存命中率更高。

## 本节小结

COPY 是最常用的文件复制指令，ADD 只在其自动解压功能真正需要时才用。COPY 顺序至关重要：先拷依赖文件再拷源码，可以让 `npm install` 等耗时操作被缓存，大幅提升构建速度。

## 下一节预告

下一节我们一站式讲解 WORKDIR、ENV、EXPOSE、ARG、USER、LABEL 等配置指令。
