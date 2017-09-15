FROM debian:9

RUN apt-get update -qq && apt-get install -yf \
	imagemagick \
	graphicsmagick \
	tesseract-ocr \
	tesseract-ocr-ara \
	tesseract-ocr-jpn \
	tesseract-ocr-fra \
	tesseract-ocr-eng \
	tesseract-ocr-spa \
	pdftk \
	libreoffice \
	poppler-utils \
	poppler-data \
	ghostscript \
	openjdk-8-jdk \
	libicu57 \
	redis-server \
	postgresql-9.6-postgis-2.3 \
	postgresql-contrib-9.6 \
	libcurl4-openssl-dev \
	libgeos-dev \
	libgeos++-dev \
	libproj-dev \
	libpq-dev \
	libxml2-dev \
	libxslt1-dev \
	zlib1g-dev \
	libicu-dev \
	libqtwebkit-dev \
	build-essential \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale && echo "LANG=en_US.UTF-8" >> /etc/default/locale && locale-gen en_US en_US.UTF-8 && \
	dpkg-reconfigure locales

ENV GITHUB_OAUTH_TOKEN 12526f5306239359dfba56b197eccede79cd1b10
RUN echo "[url \"https://${GITHUB_OAUTH_TOKEN}@github.com/\"]\n  insteadOf = git@github.com:" > /etc/gitconfig

# Copy Gemfile first, and run bundle install so that the result gets cached in
# further runs if the Gemfile doesn't change.
COPY Gemfile ./Gemfile
# COPY Gemfile.* ./
COPY vendor ./vendor
RUN chown -R app:app /usr/src/app

USER app
RUN gem install bundler
RUN bundle install --retry 3

USER root
ADD . /usr/src/app
RUN chown -R app:app /usr/src/app

USER app
RUN CRON=0 DEVISE_SECRET_KEY=12345678 DATABASE_URL=postgres://foo:bar@127.0.0.1/foobar SECRET_TOKEN=foobar RAILS_ENV=production bundle exec rake assets:precompile

# RUN DATABASE_URL=sqlite3:///tmp/fake.db bundle exec rake reporting:compile

CMD ["./docker/web"]
