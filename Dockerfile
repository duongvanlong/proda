FROM ruby:2.5

RUN apt-get update && apt-get install -y wget vim curl

RUN gem install rails -v 5.2.1

RUN mkdir /proda && mkdir -p /var/run/sshd

RUN echo 'alias ll="ls -l"' >> /root/.bashrc

WORKDIR /proda

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install && rm Gemfile && rm Gemfile.lock
