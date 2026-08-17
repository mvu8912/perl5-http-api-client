FROM perl:latest

USER root

COPY src /app/src

WORKDIR /app/src

ENV PERL5LIB=/app/src/lib

RUN cpanm --installdeps .

CMD ["prove", "-r", "t"]
