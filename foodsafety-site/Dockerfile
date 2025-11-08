# Dockerfile
FROM nginx:alpine

# 複製構建好的文件
COPY dist/ /usr/share/nginx/html

# 複製 nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]