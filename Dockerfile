FROM httplab/ruby-app:2.3-xenial

ENV PORT 3000

USER $USER

EXPOSE $PORT/tcp

CMD bundle exec puma -p $PORT -e $RACK_ENV -t 0:5
