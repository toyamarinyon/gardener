gulp   = require 'gulp'
coffee = require 'gulp-coffee'
webserver   = require 'gulp-webserver'

gulp.task 'default', ['build:coffee']
gulp.task 'development', ['webserver','build:coffee'], ->
  gulp.watch 'src/**/*.coffee', ['build:coffee']

gulp.task 'build:coffee', ->
  gulp.src 'src/**/*.coffee'
    .pipe coffee
      bare: true
    .pipe gulp.dest('Commands')

gulp.task 'webserver', ->
  gulp.src './'
    .pipe webserver
      livereload: true
      host: '0.0.0.0'
