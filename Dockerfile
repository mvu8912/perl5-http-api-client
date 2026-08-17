FROM michaelpc/openshift:latest 

USER root

COPY src /app/src

WORKDIR /app/src

RUN cpanm --installdeps .

CMD ["prove", "-r", "t"]
