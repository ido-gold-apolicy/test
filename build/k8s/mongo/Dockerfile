FROM mongo:4.2.8
COPY ./*.js /docker-entrypoint-initdb.d/

ENV MONGO_INITDB_ROOT_USERNAME=root
ENV MONGO_INITDB_ROOT_PASSWORD=password

CMD ["--replSet", "rs0"]