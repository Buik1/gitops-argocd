FROM nginx:alpine

COPY web-content/v1/index.html /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]